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

// متغير عالمي لحفظ مرجع التايمر المستقل
static dispatch_source_t wizard_pulse_timer;

// ==========================================
// --- 🆕 وظيفة التسجيل في ملف (الصندوق الأسود) ---
// ==========================================
void writeToWizardFile(NSString *text) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Wizard_Diagnostic.txt"];
    NSString *timestamp = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
    NSString *finalText = [NSString stringWithFormat:@"[%@] %@\n", timestamp, text];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (fileHandle) {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[finalText dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    } else {
        [finalText writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

// جديد: وظيفة فرض السيادة على الدالة (Method Hijacking)
void freezeMethodLogic(NSString *className, NSString *selectorName) {
    Class cls = NSClassFromString(className);
    if (!cls) return;
    Method method = class_getInstanceMethod(cls, NSSelectorFromString(selectorName));
    if (method) {
        IMP newImp = imp_implementationWithBlock(^BOOL(id self) { return YES; });
        class_replaceMethod(cls, NSSelectorFromString(selectorName), newImp, method_getTypeEncoding(method));
        writeToWizardFile([NSString stringWithFormat:@"[FREEZE] Permanently Locked %@:%@", className, selectorName]);
    }
}

// جديد: وظيفة مسح الكلاسات للبحث عن بوابات التحقق (Radar)
void scanClassMethods(NSString *className) {
    Class cls = NSClassFromString(className);
    if (!cls) return;
    unsigned int methodCount;
    Method *methods = class_copyMethodList(cls, &methodCount);
    for (unsigned int i = 0; i < methodCount; i++) {
        SEL selector = method_getName(methods[i]);
        NSString *methodName = NSStringFromSelector(selector);
        if ([methodName containsString:@"is"] || [methodName containsString:@"check"] || [methodName containsString:@"Status"]) {
            writeToWizardFile([NSString stringWithFormat:@"[RADAR] Found in %@: %@", className, methodName]);
        }
    }
    free(methods);
}

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
    writeToWizardFile([NSString stringWithFormat:@"[UI LOG] %@", message]);
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
// --- 🆕 درع منع الإغلاق القسري (Anti-Exit) ---
// ==========================================
%hook UIApplication
- (void)terminateWithSuccess { 
    writeToWizardFile(@"[BLOCK] App tried to terminateWithSuccess");
    return; 
}
%end

%hookf(void, exit, int status) {
    writeToWizardFile([NSString stringWithFormat:@"[BLOCK] System exit(%d) called", status]);
    return; 
}

%hookf(void, abort, void) {
    writeToWizardFile(@"[BLOCK] System abort() called");
    return; 
}

// ==========================================
// --- 1️⃣ & 2️⃣: حماية البيئة وتزييف الـ Cache ---
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

%hook NSUserDefaults
- (BOOL)boolForKey:(NSString *)defaultName {
    if ([defaultName containsString:@"Activated"] || [defaultName containsString:@"Premium"] || [defaultName containsString:@"Session"]) return YES;
    return %orig;
}
- (id)objectForKey:(NSString *)defaultName {
    if ([defaultName containsString:@"ActivationKey"] || [defaultName containsString:@"license"]) return @"WIZARD-MASTER-2099";
    return %orig;
}
%end

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
        if (json[@"subscriber"] || json[@"entitlements"] || json[@"status"] || json[@"session"]) {
            writeToWizardFile(@"[JSON] Hijacking Security Object");
            mJson[@"status"] = @"success";
            mJson[@"subscriber"] = @{
                @"entitlements": @{@"premium": @{@"isActive": @YES, @"expires_date": @"2099-01-01T00:00:00Z"}},
                @"subscriptions": @{@"premium": @{@"isActive": @YES, @"expires_date": @"2099-01-01T00:00:00Z"}}
            };
            return mJson;
        }
    }
    return json;
}
%end

// ==========================================
// --- 5️⃣ & 6️⃣: القرار النهائي والوقت ---
// ==========================================

%hook NSDate
+ (instancetype)date {
    return [NSDate dateWithTimeIntervalSince1970:4070908800];
}
- (NSTimeInterval)timeIntervalSince1970 {
    NSTimeInterval val = %orig;
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
- (int)remainingTrials { return 999; }
- (BOOL)hasFeatureAccess:(id)arg1 { return YES; }
%end

// جديد: هوك لكلاسات الجلسة والتحقق الإضافية لمنع الإغلاق
%hook SessionManager
- (BOOL)isSessionValid { return YES; }
- (BOOL)isUserSubscribed { return YES; }
%end

%hook EntitlementManager
- (BOOL)hasEntitlement:(id)arg1 { return YES; }
%end

%hook NSObject
- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key containsString:@"isActivated"] || [key containsString:@"premiumStatus"] || [key containsString:@"isSubscribed"]) {
        %orig(@YES, key);
        return;
    }
    %orig;
}
%end

%hook UIAlertController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if ([self.title containsString:@"Welcome"] || [self.message containsString:@"key"] || [self.title containsString:@"Trial"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        showWizardLog(@"Activation & Session Bypass ✅");
    }
}
%end

// ==========================================
// --- المشيد المطور (إصدار النبض الثابت GCD) ---
// ==========================================

%ctor {
    writeToWizardFile(@"--- STABLE GCD SESSION START ---");
    
    // تشغيل الرادار
    NSArray *classesToScan = @[@"WizardLicenseManager", @"SessionManager", @"EntitlementManager", @"AppController"];
    for (NSString *name in classesToScan) { scanClassMethods(name); }

    // تجميد المنطق بشكل جذري (Permanent Overrides)
    freezeMethodLogic(@"WizardLicenseManager", @"isActivated");
    freezeMethodLogic(@"RCCustomerInfo", @"isPremium");
    freezeMethodLogic(@"SessionManager", @"isSessionValid");

    // جديد: استخدام GCD Timer بدلاً من NSTimer لضمان الاستقرار في Thread الخلفية
    dispatch_queue_t pulseQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    wizard_pulse_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, pulseQueue);
    
    if (wizard_pulse_timer) {
        dispatch_source_set_timer(wizard_pulse_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(wizard_pulse_timer, ^{
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"isWizardActivated"];
            [defaults setBool:YES forKey:@"isPremium"];
            [defaults synchronize];
            
            static int pulse_count = 0;
            if (++pulse_count % 5 == 0) {
                writeToWizardFile(@"[GCD PULSE] Heartbeat Stable ❤️");
            }
        });
        dispatch_resume(wizard_pulse_timer);
    }

    void (^enforce)(NSString*, NSString*) = ^(NSString* c, NSString* s) {
        Class cls = NSClassFromString(c);
        if (cls) {
            Method m = class_getInstanceMethod(cls, NSSelectorFromString(s));
            if (m) {
                writeToWizardFile([NSString stringWithFormat:@"[CTOR] Enforcing YES on %@:%@", c, s]);
                class_replaceMethod(cls, NSSelectorFromString(s), imp_implementationWithBlock(^BOOL(id self){ return YES; }), method_getTypeEncoding(m));
            }
        }
    };

    enforce(@"WizardLicenseManager", @"isActivated");
    enforce(@"RCCustomerInfo", @"isPremium");
    enforce(@"GameSession", @"isValid");
    enforce(@"SessionManager", @"isSessionValid");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showWizardLog(@"GCD Pulse & Independence Active ✅");
    });
}
