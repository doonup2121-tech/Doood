#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

// دالة سريعة جداً لإظهار التنبيه
void showFastAlert(NSString *msg) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    window = scene.windows.firstObject;
                    break;
                }
            }
        } else {
            window = [UIApplication sharedApplication].keyWindow;
        }

        if (window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                          message:msg 
                                          preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:0 handler:nil]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

__attribute__((constructor)) static void doonEntry() {
    // 1. محاولة ربط المكتبة القديمة فوراً
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    // 2. تنفيذ التعديلات خلال نص ثانية فقط (عشان نضمن إن الكلاسات اتحملت)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        Class wizardCls = objc_getClass("Wizard");
        
        if (wizardCls) {
            // تفعيل الباسورد والـ VIP
            IMP passImp = imp_implementationWithBlock(^BOOL(id self, SEL _cmd, NSString *input) {
                return [input isEqualToString:@"12345"];
            });
            class_replaceMethod(wizardCls, @selector(checkKey:), passImp, "B@:@");

            IMP vipImp = imp_implementationWithBlock(^BOOL(id self){ return YES; });
            class_replaceMethod(wizardCls, @selector(isKeyValid), vipImp, "B@:");
            class_replaceMethod(wizardCls, @selector(isVip), vipImp, "B@:");

            showFastAlert(@"Wizard Modded Successfully! ✅\nPass: 12345");
        } else {
            // لو ملقاش الكلاس في أول نص ثانية، هيطلع تنبيه عشان تعرف المشكلة فين
            showFastAlert(@"Error: Class 'Wizard' not found! ❌");
        }
    });
}