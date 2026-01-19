#import <UIKit/UIKit.h>
#import <sys/sysctl.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>

// --- طبقة الأمان: تعطيل دوال الانتحار (Anti-Kill Switch) ---
%hookf(void, exit, int status) { return; }
%hookf(void, abort) { return; }
%hookf(int, kill, pid_t pid, int sig) {
    if (pid == getpid()) return 0; // منع المكتبة من قتل العملية الحالية
    return %orig;
}

// --- طبقة التمويه: تزييف الـ sysctl (Anti-Debugging) ---
%hookf(int, sysctl, int *name, u_int namelen, void *info, size_t *infosize, void *newp, size_t newlen) {
    int result = %orig;
    if (namelen == 4 && name[0] == CTL_KERN && name[1] == KERN_PROC && name[2] == KERN_PROC_PID && info) {
        struct kinfo_proc *info_ptr = (struct kinfo_proc *)info;
        if (info_ptr->kp_proc.p_flag & P_TRACED) {
            info_ptr->kp_proc.p_flag &= ~P_TRACED; // مسح فلاج المراقبة
        }
    }
    return result;
}

// --- طبقة الشبح: إخفاء الـ dylibs و Substrate (Anti-Detection) ---
%hookf(int, access, const char *path, int mode) {
    if (path && (strstr(path, "MobileSubstrate") || strstr(path, "Cydia") || strstr(path, "libsubstitute"))) {
        return -1; // إيهام المكتبة أن ملفات الجيلبريك غير موجودة
    }
    return %orig;
}

%hookf(const char *, _dyld_get_image_name, uint32_t image_index) {
    const char *name = %orig;
    if (name && (strstr(name, "Tweak") || strstr(name, "Substrate") || strstr(name, "WizardSilent"))) {
        return "/usr/lib/libobjc.A.dylib"; // التخفي في هوية مكتبة نظام رسمية
    }
    return name;
}

// --- طبقة اختراق المنطق: تفعيل البريميوم (Logic Abuse) ---
%hook RCCustomerInfo
- (BOOL)isPremium { return YES; }
- (NSDictionary *)entitlements {
    // بناء القاموس الذي يتوقعه الـ Client-side Logic Validation
    return @{
        @"premium": @{
            @"isActive": @YES,
            @"periodType": @"annual",
            @"expiresDate": @"2099-01-01T00:00:00Z"
        }
    };
}
%end

// --- طبقة التنظيف: إخفاء واجهة المكتبة (UI Suppression) ---
%hook UIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    NSString *className = NSStringFromClass([self class]);
    // استهداف أي واجهة تحتوي على اسم المكتبة أو كلمات تفعيل
    if ([className containsString:@"Wizard"] || [className containsString:@"Activation"]) {
        [self.view setHidden:YES];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}
%end

// --- طبقة تخطي التمويه الديناميكي (dlsym Hook) ---
%hookf(void *, dlsym, void *handle, const char *symbol) {
    if (symbol && (strcmp(symbol, "ptrace") == 0 || strcmp(symbol, "sysctl") == 0)) {
        return NULL; // منع المكتبة من الوصول للدوال الحساسة ديناميكياً
    }
    return %orig;
}
