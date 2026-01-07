#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

// دالة إظهار التنبيه باستخدام الطريقة الحديثة المتوافقة مع iOS 13 وصولاً لـ iOS 18+
void showFinalDoonAlert(NSString *title, NSString *msg) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        // حل مشكلة الصورة 1175: البحث عن النافذة بدون استخدام keyWindow المحذوف
        for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *w in scene.windows) {
                    if (w.isKeyWindow) {
                        window = w;
                        break;
                    }
                }
            }
        }

        if (window && window.rootViewController) {
            // حل مشكلة الصورة 1170: استخدام الأسامي الكاملة بدلاً من الأرقام
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title 
                                          message:msg 
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" 
                                              style:UIAlertActionStyleDefault 
                                            handler:nil]];
            
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

// الكود اللي بيضرب في كل مكان (God Mode)
void applyUltimateHook(Class cls) {
    unsigned int methodCount;
    Method *methods = class_copyMethodList(cls, &methodCount);
    for (unsigned int i = 0; i < methodCount; i++) {
        SEL selector = method_getName(methods[i]);
        NSString *name = NSStringFromSelector(selector).lowercaseString;
        
        NSArray *targets = @[@"check", @"pass", @"key", @"vip", @"premium", @"valid", @"license"];
        for (NSString *target in targets) {
            if ([name containsString:target]) {
                class_replaceMethod(cls, selector, imp_implementationWithBlock(^BOOL(id self, id arg1) {
                    return YES; // إرجاع "صح" لأي عملية فحص
                }), "B@:@");
            }
        }
    }
    free(methods);
}

__attribute__((constructor)) static void startDoonEngine() {
    // محاولة فتح المكتبة القديمة من جذر اللعبة
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        int numClasses = objc_getClassList(NULL, 0);
        Class *classes = (Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);

        BOOL found = NO;
        for (int i = 0; i < numClasses; i++) {
            NSString *className = NSStringFromClass(classes[i]);
            if ([className containsString:@"Wizard"] || [className containsString:@"Cheat"]) {
                applyUltimateHook(classes[i]);
                found = YES;
            }
        }
        free(classes);
        
        showFinalDoonAlert(@"DooN Status", found ? @"Hack Applied! ✅" : @"Tweak Loaded. 🚀");
    });
}