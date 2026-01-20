#import <UIKit/UIKit.h>
#import <sys/sysctl.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>
#import <sys/stat.h>

// --- تعريفات النظام لتجنب أخطاء البناء ---
#ifndef PT_DENY_ATTACH
#define PT_DENY_ATTACH 31
#endif

extern "C" int ptrace(int request, pid_t pid, caddr_t addr, int data);

// --- دوال المساعدة للواجهة ---
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
        [alert addAction:[UIAlertAction actionWithTitle:@"استمرار ✅" style:UIAlertActionStyleDefault handler:nil]];
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
// --- 1️⃣ & 2️⃣: حماية البيئة (Anti-Debug & Jailbreak) ---
// ==========================================

%hookf(int, sysctl, int *name, u_int namelen, void *info, size_t *infosize, void *newp, size_t newlen) {
    int result = %orig;
    if (namelen == 4 && name[0] == CTL_KERN && name[1] == KERN_PROC && name[2] == KERN_PROC_PID && info) {
        struct kinfo_proc *info_ptr = (struct kinfo_proc *)info;
        if (info_ptr->kp_proc.p_flag & P_TRACED) {
            info_ptr->kp_proc.p_flag &= ~P_TRACED; 
            showWizardLog(@"Stealth: Debugger Cloaked 🛡️");
        }
    }
    return result;
}

%hookf(int, ptrace, int request, pid_t pid, caddr_t addr, int data) {
    if (request == PT_DENY_ATTACH) return 0; 
    return %orig;
}

%hookf(int, access, const char *path, int mode) {
    if (path && (strstr(path, "MobileSubstrate") || strstr(path, "Cydia") || strstr(path, ".dylib"))) return -1;
    return %orig;
}

// ==========================================
// --- 3️⃣ & 4️⃣: اختطاف مصدر البيانات (JSON & dlsym) ---
// ==========================================

%hookf(void *, dlsym, void *handle, const char *symbol) {
    if (symbol && (strstr(symbol, "isActivated") || strstr(symbol, "isPremium"))) {
        showWizardLog([NSString stringWithFormat:@"Symbol Redirect: %s", symbol]);
        return (void *)objc_msgSend; 
    }
    return %orig;
}

%hook NSJSONSerialization
+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error {
    id json = %orig;
    if ([json isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mJson = [json mutableCopy];
        // تزييف هيكلي شامل لضمان قبول البيانات من أي سيرفر
        if (json[@"subscriber"] || json[@"entitlements"] || json[@"status"]) {
            mJson[@"status"] = @"success";
            mJson[@"subscriber"] = @{
                @"entitlements": @{@"premium": @{@"isActive": @YES, @"expires_date": @"2099-01-01T00:00:00Z"}},
                @"subscriptions": @{@"premium": @{@"expires_date": @"2099-01-01T00:00:00Z"}}
            };
            return mJson;
        }
    }
    return json;
}
%end

// ==========================================
// --- 5️⃣ & 6️⃣: القرار النهائي والوقت (The Source of Truth) ---
// ==========================================

%hook NSDate
+ (instancetype)date {
    // إرجاع تاريخ ثابت (سنة 2099) لكل طلبات الوقت
    return [NSDate dateWithTimeIntervalSince1970:4070908800];
}
- (NSTimeInterval)timeIntervalSince1970 {
    NSTimeInterval val = %orig;
    // أي مقارنة زمنية للتحقق من الصلاحية ستعبر دائماً
    if (val < 2524608000) return 4070908800; 
    return val;
}
%end

%hook RCCustomerInfo
- (BOOL)isPremium { return YES; }
- (NSDictionary *)entitlements {
    return @{@"premium": @{@"isActive": @YES, @"expiresDate": @"2099-01-01T00:00:00Z"}};
}
%end

%hook WizardLicenseManager 
- (BOOL)isActivated { return YES; }
- (BOOL)checkLicense:(id)arg1 { return YES; } 
- (int)licenseStatus { return 1; }
- (id)serverDate { return [NSDate date]; }
%end

// معالجة واجهة التفعيل المكتشفة في الصورة
%hook UIAlertController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if ([self.title containsString:@"Welcome"] || [self.message containsString:@"key"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        showWizardLog(@"Activation Bypass: Consistently Handled ✅");
    }
}
%end

%ctor {
    NSLog(@"[WizardMaster] Universal Logic Hijacking Active.");
    
    // فرض الهوك على مستوى الذاكرة لضمان عدم الالتفاف
    void (^enforce)(NSString*, NSString*) = ^(NSString* c, NSString* s) {
        Class cls = NSClassFromString(c);
        if (cls) {
            Method m = class_getInstanceMethod(cls, NSSelectorFromString(s));
            if (m) class_replaceMethod(cls, NSSelectorFromString(s), imp_implementationWithBlock(^BOOL(id self){ return YES; }), method_getTypeEncoding(m));
        }
    };

    enforce(@"WizardLicenseManager", @"isActivated");
    enforce(@"RCCustomerInfo", @"isPremium");
}
