#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

// دالة سحرية لحقن أي ميثود مجهول
void forceEverything(Class cls) {
    unsigned int methodCount;
    Method *methods = class_copyMethodList(cls, &methodCount);
    for (unsigned int i = 0; i < methodCount; i++) {
        SEL selector = method_getName(methods[i]);
        NSString *name = NSStringFromSelector(selector);
        
        // لو اسم الدالة فيه أي كلمة من دول، افتحها فوراً
        NSArray *targets = @[@"check", @"pass", @"key", @"vip", @"premium", @"valid", @"license", @"verify", @"status"];
        for (NSString *target in targets) {
            if ([name.lowercaseString containsString:target]) {
                class_replaceMethod(cls, selector, imp_implementationWithBlock(^BOOL(id self, id arg1) {
                    return YES; // الإجابة دايماً "نعم"
                }), "B@:@");
            }
        }
    }
    free(methods);
}

__attribute__((constructor)) static void doonGodMode() {
    // محاولة فتح المكتبة القديمة بكل الطرق الممكنة
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);
    dlopen("wizardcrackv2.dylib", RTLD_NOW);

    // اشتغل فوراً + بعد ثانية لضمان تخطي الحماية
    void (^block)(void) = ^{
        // 1. تفعيل كل الكلاسات المحتملة
        int numClasses = objc_getClassList(NULL, 0);
        Class *classes = (Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);

        for (int i = 0; i < numClasses; i++) {
            NSString *className = NSStringFromClass(classes[i]);
            // استهداف الكلاسات اللي تبع الهاك أو اللعبة
            if ([className containsString:@"Wizard"] || [className containsString:@"Menu"] || [className containsString:@"Cheat"]) {
                forceEverything(classes[i]);
            }
        }
        free(classes);

        // 2. إظهار رسالة النجاح
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            if (window.rootViewController) {
                UIAlertController *a = [UIAlertController alertControllerWithTitle:@"DooN GOD MODE" 
                                              message:@"All Engines Started! ✅\nEverything Unlocked." 
                                              preferredStyle:1];
                [a addAction:[UIAlertAction actionWithTitle:@"OK" style:0 handler:nil]];
                [window.rootViewController presentViewController:a animated:YES completion:nil];
            }
        });
    };

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}