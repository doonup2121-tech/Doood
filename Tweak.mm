#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

// دالة سريعة لإظهار التنبيه - تم تصحيح الأنواع هنا
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

        if (window && window.rootViewController) {
            // تصحيح: استخدمنا UIAlertControllerStyleAlert بدلاً من رقم 1
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                          message:msg 
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            // تصحيh: استخدمنا UIAlertActionStyleDefault بدلاً من رقم 0
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" 
                                                         style:UIAlertActionStyleDefault 
                                                       handler:nil];
            [alert addAction:ok];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

__attribute__((constructor)) static void doonEntry() {
    // ربط المكتبة اللي في الجذر
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        Class wizardCls = objc_getClass("Wizard");
        if (wizardCls) {
            class_replaceMethod(wizardCls, @selector(checkKey:), imp_implementationWithBlock(^BOOL(id self, SEL _cmd, NSString *input) {
                return [input isEqualToString:@"12345"];
            }), "B@:@");
            class_replaceMethod(wizardCls, @selector(isKeyValid), imp_implementationWithBlock(^BOOL(id self){ return YES; }), "B@:");
            class_replaceMethod(wizardCls, @selector(isVip), imp_implementationWithBlock(^BOOL(id self){ return YES; }), "B@:");
            showFastAlert(@"Wizard Modded! ✅\nPass: 12345");
        } else {
            showFastAlert(@"Tweak Injected! Class not found. ⚠️");
        }
    });
}