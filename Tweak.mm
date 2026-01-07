#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach/mach.h>

// حذفنا دالة doonLockSystem اللي كانت بتعدل الـ exit عشان اللعبة تفتح

__attribute__((constructor)) static void startDoonSafe() {
    // 1. تحميل صامت للمكتبات بدون تدخل في النظام
    void* wizard = dlopen("@executable_path/Frameworks/Wizard.framework/Wizard", RTLD_NOW);
    void* crack = dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    // 2. انتظر 20 ثانية كاملة (تأخير طويل جداً لضمان تخطي فحص البداية)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    window = scene.windows.firstObject;
                    break;
                }
            }
        }
        if (!window) window = [UIApplication sharedApplication].windows.firstObject;

        if (window.rootViewController) {
            // رسالة بسيطة للتأكد من أن التويك شغال
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Raid" 
                                          message:@"Safe Mode Loaded ✅\nTry to login now." 
                                          preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}