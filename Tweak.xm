#import <UIKit/UIKit.h>
#import <sys/sysctl.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>

// --- إضافة دالة التنبيه الإجباري (للتأكد من أن الحقن تم بنجاح) ---
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
        [alert addAction:[UIAlertAction actionWithTitle:@"تم التفعيل ✅" style:UIAlertActionStyleDefault handler:nil]];
        
        UIViewController *rootVC = window.rootViewController;
        while (rootVC.presentedViewController) { rootVC = rootVC.presentedViewController; }
        [rootVC presentViewController:alert animated:YES completion:nil];
    });
}

// --- إضافة تقنية الاستغناء عن الرابط (Runtime Helper) ---
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
        
        [UIView animateWithDuration:0.5 delay:2.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    });
}

// --- طبقة الأمان: Anti-Kill Switch ---
%hookf(void, exit, int status) { 
    showWizardLog(@"Blocked Exit Attempt");
    if (status == 0) %orig; return; 
}
%hookf(void, abort) { 
    showWizardLog(@"Blocked Abort Attempt");
    return; 
}

// --- طبقة التمويه: Anti-Debugging ---
%hookf(int, sysctl, int *name, u_int namelen, void *info, size_t *infosize, void *newp, size_t newlen) {
    int result = %orig;
    if (namelen == 4 && name[0] == CTL_KERN && name[1] == KERN_PROC && name[2] == KERN_PROC_PID && info) {
        struct kinfo_proc *info_ptr = (struct kinfo_proc *)info;
        if (info_ptr->kp_proc.p_flag & P_TRACED) {
            info_ptr->kp_proc.p_flag &= ~P_TRACED; 
            showWizardLog(@"Debugger Hidden (sysctl)");
        }
    }
    return result;
}

// --- طبقة الشبح: Anti-Detection ---
%hookf(int, access, const char *path, int mode) {
    if (path && (strstr(path, "MobileSubstrate") || strstr(path, "Cydia"))) {
        showWizardLog(@"Bypassed File Check");
        return -1; 
    }
    return %orig;
}

// --- طبقة البريميوم: Logic Abuse ---
%hook RCCustomerInfo
- (BOOL)isPremium { 
    showWizardLog(@"Premium: YES");
    return YES; 
}
- (NSDictionary *)entitlements {
    showWizardLog(@"Injecting Entitlements...");
    return @{
        @"premium": @{@"isActive": @YES, @"periodType": @"annual", @"expiresDate": @"2099-01-01T00:00:00Z"},
        @"pro": @{@"isActive": @YES, @"expiresDate": @"2099-01-01T00:00:00Z"}
    };
}
%end

%hook WizardLicenseManager 
- (BOOL)isActivated { 
    showWizardLog(@"Activation Bypass: OK");
    return YES; 
}
%end

// --- طبقة التنظيف: UI Suppression ---
%hook UIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    NSString *className = NSStringFromClass([self class]);
    if ([className containsString:@"Wizard"] || [className containsString:@"Activation"] || [className containsString:@"Subscription"]) {
        showWizardLog(@"Blocking Activation UI...");
        [self.view setHidden:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            showWizardLog(@"UI Dismissed Successfully");
        });
    }
}
%end

// --- منع كشف الجيلبريك عبر الملفات ---
%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
    if ([path containsString:@"Cydia"] || [path containsString:@"apt"]) {
        showWizardLog(@"Stealth: File Hidden");
        return NO;
    }
    return %orig;
}
%end

// إشعار البدء الرئيسي
%ctor {
    NSLog(@"[WizardMaster] Injected!");
    
    // تقنية الـ Fallback اليدوية لضمان العمل بدون Substrate
    Class rcClass = NSClassFromString(@"RCCustomerInfo");
    if (rcClass) {
        Method m = class_getInstanceMethod(rcClass, NSSelectorFromString(@"isPremium"));
        if (m) {
            class_replaceMethod(rcClass, NSSelectorFromString(@"isPremium"), imp_implementationWithBlock(^BOOL(id self) {
                return YES;
            }), method_getTypeEncoding(m));
        }
    }

    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        showWizardLog(@"WizardMaster: Standalone Mode Active ✅");
        // إظهار تنبيه التأكيد الإجباري بعد 4 ثوانٍ
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            showForcedAlert(@"WizardMaster", @"تم حقن المكتبة وتفعيل البريميوم بنجاح!\nلا حاجة لروابط خارجية ✅");
        });
    }];
}
