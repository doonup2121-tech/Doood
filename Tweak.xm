#import <UIKit/UIKit.h>
#import <sys/sysctl.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>

// --- طبقة الأمان: تعطيل دوال الانتحار (Anti-Kill Switch) ---
%hookf(void, exit, int status) { return; }
%hookf(void, abort) { return; }
%hookf(int, kill, pid_t pid, int sig) {
    if (pid == getpid()) return 0; 
    return %orig;
}

// --- طبقة التمويه: تزييف الـ sysctl (Anti-Debugging) ---
%hookf(int, sysctl, int *name, u_int namelen, void *info, size_t *infosize, void *newp, size_t newlen) {
    int result = %orig;
    if (namelen == 4 && name[0] == CTL_KERN && name[1] == KERN_PROC && name[2] == KERN_PROC_PID && info) {
        struct kinfo_proc *info_ptr = (struct kinfo_proc *)info;
        if (info_ptr->kp_proc.p_flag & P_TRACED) {
            info_ptr->kp_proc.p_flag &= ~P_TRACED; 
        }
    }
    return result;
}

// --- طبقة الشبح: إخفاء الـ dylibs و Substrate (Anti-Detection) ---
%hookf(int, access, const char *path, int mode) {
    if (path && (strstr(path, "MobileSubstrate") || strstr(path, "Cydia") || strstr(path, "libsubstitute"))) {
        return -1; 
    }
    return %orig;
}

%hookf(const char *, _dyld_get_image_name, uint32_t image_index) {
    const char *name = %orig;
    if (name && (strstr(name, "Tweak") || strstr(name, "Substrate") || strstr(name, "WizardSilent") || strstr(name, "WizardMaster"))) {
        return "/usr/lib/libobjc.A.dylib"; 
    }
    return name;
}

// --- طبقة اختراق المنطق: تفعيل البريميوم وتخطي شاشة الكود (Logic Abuse) ---
// استهداف كلاس الـ RevenueCat الشهير وكلاسات الحماية العامة
%hook RCCustomerInfo
- (BOOL)isPremium { return YES; }
- (NSDictionary *)entitlements {
    return @{
        @"premium": @{
            @"isActive": @YES,
            @"periodType": @"annual",
            @"expiresDate": @"2099-01-01T00:00:00Z"
        }
    };
}
%end

// --- إضافة قوية: تخطي التحقق من "صحة الكود" (Validation Bypass) ---
%hook WizardLicenseManager // افتراضاً لاسم الكلاس المسؤول عن الكود
- (BOOL)isActivated { return YES; }
- (BOOL)isValidLicense:(id)arg1 { return YES; }
- (id)expirationDate { return [NSDate dateWithTimeIntervalSinceNow:315360000]; } // 10 سنوات
%end

// --- طبقة التنظيف: إخفاء واجهة المكتبة وشاشة التفعيل (UI Suppression) ---
%hook UIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    NSString *className = NSStringFromClass([self class]);
    
    // إذا كانت الواجهة هي واجهة تفعيل الكود، سنقوم بإخفائها فوراً والدخول للعبة
    if ([className containsString:@"Wizard"] || 
        [className containsString:@"Activation"] || 
        [className containsString:@"Login"] || 
        [className containsString:@"Subscription"]) {
        
        [self.view setHidden:YES];
        // محاولة العودة للخلف أو إغلاق الواجهة المنبثقة للوصول للقائمة الرئيسية
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}
%end

// --- طبقة تخطي التمويه الديناميكي (dlsym Hook) ---
%hookf(void *, dlsym, void *handle, const char *symbol) {
    if (symbol && (strcmp(symbol, "ptrace") == 0 || strcmp(symbol, "sysctl") == 0)) {
        return NULL; 
    }
    return %orig;
}

// إشعار عند التشغيل للتأكد أن المكتبة تعمل
%ctor {
    NSLog(@"[WizardMaster] Library Injected Successfully!");
}
