#import <UIKit/UIKit.h>
#import <sys/sysctl.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>
#import <sys/stat.h>
#import <execinfo.h> // ضروري لتحليل الـ Backtrace

// --- تعريفات النظام لتجنب أخطاء البناء ---
#ifndef PT_DENY_ATTACH
#define PT_DENY_ATTACH 31
#endif

extern "C" int ptrace(int request, pid_t pid, caddr_t addr, int data);

static dispatch_source_t wizard_pulse_timer;
// 🆕 متغير التحكم في "نقطة التحول"
static BOOL is_environment_stable = NO;

// ==========================================
// --- وظيفة التسجيل في ملف ---
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
        [finalText writeToFile:filePath atomically:YES encoding:UTF8StringEncoding error:nil];
    }
}

// 🆕 وظيفة الرادار المطور: يركز على المكتبات الخارجية (External SDKs) + استبعاد المتجر
void ultraWideRadar() {
    // لا يعمل الرادار الفعلي إلا بعد استقرار البيئة
    if (!is_environment_stable) return;

    // 1. تحديد اسم ملف اللعبة الأساسي لاستبعاده من الرصد المركز
    const char *mainExecutablePath = _dyld_get_image_name(0);
    NSString *mainBinaryName = [[NSString stringWithUTF8String:mainExecutablePath] lastPathComponent];

    int numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0) {
        Class *classes = (Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            Class cls = classes[i];
            NSString *className = NSStringFromClass(cls);
            
            // 🛑 فلتر استبعاد المتجر (Store) من الكلاسات
            if ([className rangeOfString:@"Store" options:NSCaseInsensitiveSearch].location != NSNotFound) continue;
            
            // فحص كلاسات اللعبة فقط وتجاهل كلاسات النظام لزيادة السرعة
            if ([className hasPrefix:@"NS"] || [className hasPrefix:@"UI"] || [className hasPrefix:@"_"] || [className hasPrefix:@"CA"]) continue;

            // 2. الحصول على اسم المكتبة التي ينتمي إليها الكلاس
            const char *imagePath = class_getImageName(cls);
            NSString *libraryName = (imagePath != NULL) ? [[NSString stringWithUTF8String:imagePath] lastPathComponent] : @"Unknown";

            unsigned int methodCount;
            Method *methods = class_copyMethodList(cls, &methodCount);
            for (unsigned int j = 0; j < methodCount; j++) {
                SEL selector = method_getName(methods[j]);
                NSString *methodName = NSStringFromSelector(selector);
                
                // 🛑 فلتر استبعاد المتجر (Store) من الدوال
                if ([methodName rangeOfString:@"Store" options:NSCaseInsensitiveSearch].location != NSNotFound) continue;

                const char* typeEncoding = method_getTypeEncoding(methods[j]);

                // لقط أي دالة تعيد BOOL (توقيعها يحتوي على B) أو تحتوي على كلمات تحكم
                if (typeEncoding != NULL && (strstr(typeEncoding, "B") != NULL || 
                    [methodName containsString:@"check"] || 
                    [methodName containsString:@"verify"] || 
                    [methodName containsString:@"valid"])) {
                    
                    static NSMutableSet *loggedMethods;
                    if (!loggedMethods) loggedMethods = [NSMutableSet set];
                    
                    // تحديد ما إذا كانت الدالة خارجية (External SDK) أو داخلية (Main App)
                    NSString *originTag = [libraryName isEqualToString:mainBinaryName] ? @"[APP-INTERNAL]" : [NSString stringWithFormat:@"[SDK:%@]", libraryName];
                    NSString *signature = [NSString stringWithFormat:@"%@ %@:%@ (%s)", originTag, className, methodName, typeEncoding];
                    
                    if (![loggedMethods containsObject:signature]) {
                        // 🆕 هنا الرادار يكتب فقط الأهداف "الصافية" (بدون Store)
                        writeToWizardFile([NSString stringWithFormat:@"[PURE-TARGET] %@", signature]);
                        [loggedMethods addObject:signature];
                    }
                }
            }
            free(methods);
        }
        free(classes);
    }
}

// وظيفة فرض السيادة (Method Hijacking)
void freezeMethodLogic(NSString *className, NSString *selectorName) {
    Class cls = NSClassFromString(className);
    if (!cls) return;
    Method method = class_getInstanceMethod(cls, NSSelectorFromString(selectorName));
    if (method) {
        // تمكين التجميد على YES (1)
        IMP newImp = imp_implementationWithBlock(^BOOL(id self) { return YES; });
        class_replaceMethod(cls, NSSelectorFromString(selectorName), newImp, method_getTypeEncoding(method));
        writeToWizardFile([NSString stringWithFormat:@"[FREEZE] Permanently Locked %@:%@", className, selectorName]);
    }
}

// 🆕 وظيفة إضافية للتجميد على NO (0) - للدوال مثل isLinkDown
void freezeMethodLogicToFalse(NSString *className, NSString *selectorName) {
    Class cls = NSClassFromString(className);
    if (!cls) return;
    Method method = class_getInstanceMethod(cls, NSSelectorFromString(selectorName));
    if (method) {
        IMP newImp = imp_implementationWithBlock(^BOOL(id self) { return NO; });
        class_replaceMethod(cls, NSSelectorFromString(selectorName), newImp, method_getTypeEncoding(method));
        writeToWizardFile([NSString stringWithFormat:@"[FREEZE-FALSE] Locked to NO %@:%@", className, selectorName]);
    }
}

// الرادار الديناميكي (الأصلي)
void dynamicEnforcementRadar() {
    if (!is_environment_stable) return;

    NSArray *keywords = @[@"License", @"Subscription", @"Entitlement", @"Activation", @"Premium"]; // تمت إزالة Store من الكلمات المفتاحية
    int numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0) {
        Class *classes = (Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            NSString *className = NSStringFromClass(classes[i]);
            // استبعاد المتجر هنا أيضاً
            if ([className rangeOfString:@"Store" options:NSCaseInsensitiveSearch].location != NSNotFound) continue;

            for (NSString *key in keywords) {
                if ([className rangeOfString:key options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    if ([className hasPrefix:@"NS"] || [className hasPrefix:@"UI"]) continue;
                    unsigned int methodCount;
                    Method *methods = class_copyMethodList(classes[i], &methodCount);
                    for (unsigned int j = 0; j < methodCount; j++) {
                        NSString *methodName = NSStringFromSelector(method_getName(methods[j]));
                        if ([methodName hasPrefix:@"is"] || [methodName containsString:@"check"] || [methodName containsString:@"Valid"]) {
                            freezeMethodLogic(className, methodName);
                        }
                    }
                    free(methods);
                }
            }
        }
        free(classes);
    }
}

// وظيفة مسح الكلاسات للبحث عن بوابات التحقق
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
// --- درع منع الإغلاق مع تحليل المسار (Backtrace) ---
// ==========================================
%hook UIApplication
- (void)terminateWithSuccess { 
    writeToWizardFile(@"[BLOCK] App tried to terminateWithSuccess");
    return; 
}
%end

%hookf(void, exit, int status) {
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, frames);
    
    writeToWizardFile([NSString stringWithFormat:@"[CRITICAL] Exit(%d) called! Trace:", status]);
    for (int i = 0; i < frames; i++) {
        writeToWizardFile([NSString stringWithFormat:@"  - %s", strs[i]]);
    }
    free(strs);
    return; 
}

%hookf(void, abort, void) {
    writeToWizardFile(@"[CRITICAL] Abort() called - Trace Logged");
    return; 
}

// ==========================================
// --- هوكات الحماية وتزييف البيانات ---
// ==========================================

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

%hookf(int, ptrace, int request, pid_t pid, caddr_t addr, int data) {
    if (request == PT_DENY_ATTACH) return 0; 
    return %orig;
}

%hook NSUserDefaults
- (BOOL)boolForKey:(NSString *)defaultName {
    // لا نتدخل في القيم إلا بعد استقرار البيئة
    if (is_environment_stable) {
        if ([defaultName containsString:@"Activated"] || [defaultName containsString:@"Premium"] || [defaultName containsString:@"Session"]) return YES;
    }
    return %orig;
}
%end

%hook NSJSONSerialization
+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error {
    id json = %orig;
    if (is_environment_stable && [json isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mJson = [json mutableCopy];
        if (json[@"subscriber"] || json[@"status"]) {
            mJson[@"status"] = @"success";
            mJson[@"subscriber"] = @{@"entitlements": @{@"premium": @{@"isActive": @YES}}};
            return mJson;
        }
    }
    return json;
}
%end

%hook WizardLicenseManager 
- (BOOL)isActivated { 
    return is_environment_stable ? YES : %orig; 
}
- (int)licenseStatus { 
    return is_environment_stable ? 1 : %orig; 
}
%end

// ==========================================
// --- المشيد المطور ---
// ==========================================

%ctor {
    writeToWizardFile(@"--- STAGE 1: OBSERVATION MODE START (RADAR ARMED) ---");

    dispatch_queue_t pulseQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    wizard_pulse_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, pulseQueue);
    
    if (wizard_pulse_timer) {
        dispatch_source_set_timer(wizard_pulse_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(wizard_pulse_timer, ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIWindow *win = get_SafeKeyWindow();
                if (win && win.rootViewController && !is_environment_stable) {
                    is_environment_stable = YES;
                    writeToWizardFile(@"--- STAGE 2: STABILITY REACHED. DEPLOYING PURE RADAR ---");
                    
                    // 🆕 تنفيذ الاستنتاجات النهائية فور الاستقرار
                    freezeMethodLogicToFalse(@"CWFLinkChangeStatus", @"isLinkDown");
                    freezeMethodLogicToFalse(@"CWFLinkChangeStatus", @"isInvoluntaryLinkDown");
                    freezeMethodLogic(@"CHBPrivacyStore", @"consentsValidator");
                    freezeMethodLogic(@"CHBPrivacyStore", @"isConsented:");
                    freezeMethodLogic(@"NEHotspot", @"isEnabled");
                    
                    dynamicEnforcementRadar();
                    ultraWideRadar(); 
                    freezeMethodLogic(@"WizardLicenseManager", @"isActivated");
                    
                    showWizardLog(@"Targeting External Logic - Store Excluded ✅");
                }
            });

            if (is_environment_stable) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isWizardActivated"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                static int pulse_count = 0;
                pulse_count++;
                
                if (pulse_count % 5 == 0) {
                    ultraWideRadar(); 
                    dynamicEnforcementRadar();
                }
                
                if (pulse_count % 10 == 0) {
                    writeToWizardFile(@"[PULSE] Analysis Consistent - Monitoring SDKs ❤️");
                }
            }
        });
        dispatch_resume(wizard_pulse_timer);
    }
}
