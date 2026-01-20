#import <UIKit/UIKit.h>
#import <sys/sysctl.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>
#import <sys/stat.h>
#import <execinfo.h>

#ifndef PT_DENY_ATTACH
#define PT_DENY_ATTACH 31
#endif

extern "C" int ptrace(int request, pid_t pid, caddr_t addr, int data);

static dispatch_source_t wizard_pulse_timer;
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
        [finalText writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

// وظيفة فرض السيادة (Method Hijacking)
void freezeMethodLogic(NSString *className, NSString *selectorName) {
    Class cls = NSClassFromString(className);
    if (!cls) return;
    Method method = class_getInstanceMethod(cls, NSSelectorFromString(selectorName));
    if (method) {
        IMP newImp = imp_implementationWithBlock(^BOOL(id self) { 
            // تسجيل كل مرة يتم فيها استدعاء الدالة
            writeToWizardFile([NSString stringWithFormat:@"[ACTION] Library requested: %@ -> %@", className, selectorName]);
            return YES; 
        });
        class_replaceMethod(cls, NSSelectorFromString(selectorName), newImp, method_getTypeEncoding(method));
        writeToWizardFile([NSString stringWithFormat:@"[FREEZE] Permanently Locked %@:%@", className, selectorName]);
    }
}

void freezeMethodLogicToFalse(NSString *className, NSString *selectorName) {
    Class cls = NSClassFromString(className);
    if (!cls) return;
    Method method = class_getInstanceMethod(cls, NSSelectorFromString(selectorName));
    if (method) {
        IMP newImp = imp_implementationWithBlock(^BOOL(id self) { 
            writeToWizardFile([NSString stringWithFormat:@"[ACTION] Library requested NO: %@ -> %@", className, selectorName]);
            return NO; 
        });
        class_replaceMethod(cls, NSSelectorFromString(selectorName), newImp, method_getTypeEncoding(method));
        writeToWizardFile([NSString stringWithFormat:@"[FREEZE-FALSE] Locked to NO %@:%@", className, selectorName]);
    }
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
// --- درع منع الإغلاق والمراقبة الحرجة ---
// ==========================================
%hook UIApplication
- (void)terminateWithSuccess { 
    writeToWizardFile(@"[BLOCK] App tried to terminateWithSuccess()");
    return; 
}
%end

%hookf(void, exit, int status) {
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, frames);
    writeToWizardFile([NSString stringWithFormat:@"[CRITICAL] exit(%d) called! Origin Trace:", status]);
    for (int i = 0; i < frames; i++) { writeToWizardFile([NSString stringWithFormat:@"  - %s", strs[i]]); }
    free(strs);
    return; 
}

%hookf(void, abort, void) {
    writeToWizardFile(@"[CRITICAL] abort() called by Library/System");
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
    BOOL original = %orig;
    if (is_environment_stable) {
        if ([defaultName containsString:@"Activated"] || [defaultName containsString:@"Premium"] || [defaultName containsString:@"Session"]) {
            writeToWizardFile([NSString stringWithFormat:@"[LOG] Preference Checked: %@ | Original: %d -> Forced: YES", defaultName, original]);
            return YES;
        }
    }
    return original;
}
%end

%hook NSJSONSerialization
+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error {
    id json = %orig;
    if (is_environment_stable && [json isKindOfClass:[NSDictionary class]]) {
        if (json[@"subscriber"] || json[@"status"]) {
            writeToWizardFile(@"[LOG] JSON Activation Data Modified");
            NSMutableDictionary *mJson = [json mutableCopy];
            mJson[@"status"] = @"success";
            mJson[@"subscriber"] = @{@"entitlements": @{@"premium": @{@"isActive": @YES}}};
            return mJson;
        }
    }
    return json;
}
%end

// مراقبة مراحل بناء كلاس الترخيص
%hook WizardLicenseManager
- (id)init {
    writeToWizardFile(@"[LIFECYCLE] WizardLicenseManager instance init called");
    return %orig;
}
- (BOOL)isActivated {
    writeToWizardFile(@"[LIFECYCLE] Library checked -> isActivated");
    return is_environment_stable ? YES : %orig;
}
%end

// ==========================================
// --- المشيد (Ctor) - عين على المكتبة ---
// ==========================================

%ctor {
    writeToWizardFile(@"--- BLACK-BOX LOGGING STARTED ---");

    // رصد المكتبة فورياً (DYLD Check)
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (strstr(name, "wizardcrackv2")) {
            writeToWizardFile([NSString stringWithFormat:@"[DYLD] Library detected at: %s", name]);
        }
    }

    dispatch_queue_t pulseQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    wizard_pulse_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, pulseQueue);
    
    if (wizard_pulse_timer) {
        dispatch_source_set_timer(wizard_pulse_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0.5 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(wizard_pulse_timer, ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIWindow *win = get_SafeKeyWindow();
                
                if (win && win.rootViewController && !is_environment_stable) {
                    is_environment_stable = YES;
                    writeToWizardFile(@"--- STAGE: INJECTION DEPLOYED ---");
                    
                    freezeMethodLogic(@"ALCSubscription", @"isActive");
                    freezeMethodLogic(@"WizardLicenseManager", @"isActivated");
                    freezeMethodLogic(@"MCActivationUtilities", @"isActivated");
                    
                    showWizardLog(@"Monitoring Active ✅");
                    dispatch_source_cancel(wizard_pulse_timer);
                }
            });
        });
        dispatch_resume(wizard_pulse_timer);
    }
}
