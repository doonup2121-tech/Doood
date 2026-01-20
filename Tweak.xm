#import <UIKit/UIKit.h>
#import <sys/sysctl.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>
#import <sys/stat.h>
#import <sys/ptrace.h> // حل مشكلة معرف ptrace

// --- دوال المساعدة ---
void showForcedAlert(NSString *title, NSString *msg) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    for (UIWindow* w in scene.windows) { if (w.isKeyWindow) { window = w; break; } }
                }
            }
        }
        if (!window) window = [UIApplication sharedApplication].keyWindow;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction action_withTitle:@"تم التفعيل ✅" style:UIAlertActionStyleDefault handler:nil]];
        UIViewController *rootVC = window.rootViewController;
        while (rootVC.presentedViewController) { rootVC = rootVC.presentedViewController; }
        [rootVC presentViewController:alert animated:YES completion:nil];
    });
}

UIWindow* get_SafeKeyWindow() {
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow* window in scene.windows) {
                    if (window.isKeyWindow) return window;
                }
            }
        }
    }
    return nil; 
}

void showWizardLog(NSString *message) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = get_SafeKeyWindow();
        if (!window) return;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, window.frame.size.height - 100, window.frame.size.width - 40, 40)];
        label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"[Wizard] %@", message];
        label.font = [UIFont boldSystemFontOfSize:12];
        label.layer.cornerRadius = 10;
        label.clipsToBounds = YES;
        [window addSubview:label];
        [UIView animateWithDuration:0.5 delay:2.5 options:UIViewAnimationOptionCurveEaseOut animations:^{ label.alpha = 0; } completion:^(BOOL finished) { [label removeFromSuperview]; }];
    });
}

// ==========================================
// --- الطبقة المحدثة: كسر حماية sysctl و ptrace (Anti-Anti-Debug) ---
// ==========================================

%hookf(int, sysctl, int *name, u_int namelen, void *info, size_t *infosize, void *newp, size_t newlen) {
    int result = %orig;
    if (namelen == 4 && name[0] == CTL_KERN && name[1] == KERN_PROC && name[2] == KERN_PROC_PID && info) {
        struct kinfo_proc *info_ptr = (struct kinfo_proc *)info;
        if (info_ptr->kp_proc.p_flag & P_TRACED) {
            info_ptr->kp_proc.p_flag &= ~P_TRACED; 
            showWizardLog(@"Debugger Stealth: Active 🛡️");
        }
    }
    return result;
}

#ifndef PT_DENY_ATTACH
#define PT_DENY_ATTACH 31
#endif

%hookf(int, ptrace, int request, pid_t pid, caddr_t addr, int data) {
    if (request == PT_DENY_ATTACH) { 
        showWizardLog(@"Blocked ptrace(PT_DENY_ATTACH)");
        return 0; 
    }
    return %orig;
}

// ==========================================
// --- طبقة التزييف الكامل للملفات (Anti-Jailbreak Virtualization) ---
// ==========================================

%hookf(int, access, const char *path, int mode) {
    if (path && (strstr(path, "MobileSubstrate") || strstr(path, "Cydia") || strstr(path, "Sileo") || strstr(path, "apt") || strstr(path, ".dylib"))) {
        return -1;
    }
    return %orig;
}

%hookf(int, stat, const char *path, struct stat *buf) {
    if (path && (strstr(path, "MobileSubstrate") || strstr(path, "Cydia") || strstr(path, "libsub") || strstr(path, "Tweak"))) {
        return -1; 
    }
    return %orig;
}

%hookf(FILE *, fopen, const char *filename, const char *mode) {
    if (filename && (strstr(filename, "MobileSubstrate") || strstr(filename, "Tweak"))) {
        return NULL; 
    }
    return %orig;
}

// ==========================================
// --- طبقة صيد الدوال الديناميكية و dlsym ---
// ==========================================

%hookf(void *, dlsym, void *handle, const char *symbol) {
    void *result = %orig;
    if (symbol && (strstr(symbol, "isActivated") || strstr(symbol, "checkLicense") || strstr(symbol, "isPremium"))) {
        NSString *logMessage = [NSString stringWithFormat:@"Intercepted dlsym: %s", symbol];
        showWizardLog(logMessage);
        return (void *)objc_msgSend; 
    }
    return result;
}

// ==========================================
// --- الطبقة الجديدة: تخطي واجهة Welcome/Key تلقائياً ---
// ==========================================

%hook UIAlertController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    // الكشف عن نافذة طلب المفتاح من العنوان أو المحتوى
    if ([self.title containsString:@"Welcome"] || [self.message containsString:@"key"]) {
        showWizardLog(@"Activation Popup Detected & Bypassed ✅");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
%end

// ==========================================
// --- طبقة التمويه dyld وتزييف JSON ---
// ==========================================

%hookf(uint32_t, _dyld_image_count) { return %orig - 1; }
%hookf(const char *, _dyld_get_image_name, uint32_t image_index) {
    const char *name = %orig;
    if (name && (strstr(name, "WizardMaster") || strstr(name, "Substrate") || strstr(name, "Tweak"))) {
        return "/usr/lib/libobjc.A.dylib"; 
    }
    return name;
}

%hook NSJSONSerialization
+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error {
    id json = %orig;
    if ([json isKindOfClass:[NSDictionary class]] && (json[@"subscriber"] || json[@"entitlements"])) {
        NSMutableDictionary *mJson = [json mutableCopy];
        mJson[@"subscriber"] = @{@"entitlements": @{@"premium": @{@"isActive": @YES, @"expires_date": @"2099-01-01T00:00:00Z"}}};
        return mJson;
    }
    return json;
}
%end

// ==========================================
// --- كسر الوقت والمميزات والمنطق (Decision Hijacking) ---
// ==========================================

%hook NSDate
+ (instancetype)dateWithTimeIntervalSince1970:(NSTimeInterval)secs {
    if (secs < 2524608000) return %orig(4070908800); 
    return %orig;
}
%end

%hook RCCustomerInfo
- (BOOL)isPremium { return YES; }
- (NSDictionary *)entitlements {
    return @{
        @"premium": @{@"isActive": @YES, @"periodType": @"annual", @"expiresDate": @"2099-01-01T00:00:00Z"},
        @"pro": @{@"isActive": @YES, @"expiresDate": @"2099-01-01T00:00:00Z"},
        @"all_access": @{@"isActive": @YES, @"expiresDate": @"2099-01-01T00:00:00Z"}
    };
}
- (id)expirationDateForEntitlement:(NSString *)entitlement {
    return [NSDate dateWithTimeIntervalSince1970:4070908800];
}
%end

%hook WizardLicenseManager 
- (BOOL)isActivated { return YES; }
- (BOOL)checkLicense:(id)arg1 { return YES; } // إجبار قبول أي مفتاح يدوي
- (BOOL)isExpired { return NO; }
- (int)licenseStatus { return 1; }
- (id)serverDate { return [NSDate dateWithTimeIntervalSince1970:4070908800]; }
%end

// ==========================================
// --- المشيد الرئيسي (The Constructor) ---
// ==========================================

%ctor {
    NSLog(@"[WizardMaster] Initializing Bypasses...");

    void (^forceMemoryHook)(NSString*, NSString*) = ^(NSString* c, NSString* s) {
        Class cls = NSClassFromString(c);
        if (cls) {
            Method m = class_getInstanceMethod(cls, NSSelectorFromString(s));
            if (m) class_replaceMethod(cls, NSSelectorFromString(s), imp_implementationWithBlock(^BOOL(id self){ return YES; }), method_getTypeEncoding(m));
        }
    };

    forceMemoryHook(@"RCCustomerInfo", @"isPremium");
    forceMemoryHook(@"WizardLicenseManager", @"isActivated");

    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        showWizardLog(@"System Virtualization Active ✅");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            showForcedAlert(@"WizardMaster", @"تم تجاوز حماية المكتبة والتحقق المحلي!\nتم إخفاء نافذة طلب المفتاح تلقائياً ✅");
        });
    }];
}
