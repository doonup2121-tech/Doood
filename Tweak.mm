#import <UIKit/UIKit.h>
#import <dlfcn.h>

__attribute__((constructor)) static void startDoonFinal() {
    // تحميل المكتبات بطريقة لا تترك متغيرات غير مستخدمة
    if (dlopen("@executable_path/Frameworks/Wizard.framework/Wizard", RTLD_NOW)) {
        // تم التحميل
    }
    
    if (dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW)) {
        // تم التحميل
    }

    // الانتظار لإظهار الرسالة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
                    window = ((UIWindowScene *)scene).windows.firstObject;
                    break;
                }
            }
        }
        
        if (!window) window = [UIApplication sharedApplication].windows.firstObject;

        if (window && window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Raid" 
                                          message:@"System Ready ✅\nWait for menu..." 
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}