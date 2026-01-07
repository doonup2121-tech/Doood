#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

// دالة إظهار التنبيه بطريقة حديثة (متوافقة مع iOS 15 وصولاً لـ iOS 18.5)
void showDoonWelcome(NSString *title, NSString *msg) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
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
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title 
                                          message:msg 
                                          preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

// دالة إجبار الدوال على العمل (YES)
void forceYes(Class cls) {
    if (!cls) return;
    unsigned int methodCount;
    Method *methods = class_copyMethodList(cls, &methodCount);
    for (unsigned int i = 0; i < methodCount; i++) {
        SEL selector = method_getName(methods[i]);
        const char *type = method_getTypeEncoding(methods[i]);
        if (type && type[0] == 'B') { // استهداف دوال الـ BOOL
            class_replaceMethod(cls, selector, imp_implementationWithBlock(^BOOL(id self, id arg1) {
                return YES; 
            }), type);
        }
    }
    free(methods);
}

__attribute__((constructor)) static void startDoonStrike() {
    // 1. محاولة ربط المكتبة القديمة
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    // 2. إظهار رسالة الترحيب فوراً للتأكد من عمل المكتبة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showDoonWelcome(@"DooN Mod", @"Library Injected Successfully! ✅\nWaiting 4s to bypass password...");
    });

    // 3. تنفيذ الاختراق الشامل بعد 4 ثوانٍ
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        int numClasses = objc_getClassList(NULL, 0);
        Class *classes = (Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);

        for (int i = 0; i < numClasses; i++) {
            NSString *name = NSStringFromClass(classes[i]);
            if ([name.lowercaseString containsString:@"wizard"] || [name.lowercaseString containsString:@"menu"]) {
                forceYes(classes[i]);
                forceYes(object_getClass(classes[i]));
            }
        }
        free(classes);
    });
}