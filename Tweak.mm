#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <objc/runtime.h>

// تعريف الثوابت يدوياً لحل مشكلة الصورة 1188
#ifndef RTLD_NOW
#define RTLD_NOW 0x2
#endif

// خديعة الرد: إقناع المكتبة الوسيطة أن السيرفر وافق
@interface NSURLResponse (DoonHack)
@end

@implementation NSURLResponse (DoonHack)
- (NSInteger)statusCode {
    return 200; // إيه رد يجي، هنقول للمكتبة إنه "تمام" (OK)
}
@end

__attribute__((constructor)) static void doonUltimateBypass() {
    // 1. تحميل المنيو والمكتبة الوسيطة
    // استخدمنا القيم الرقمية لضمان نجاح الـ Build في Xcode 16.4
    void *h1 = dlopen("@executable_path/Frameworks/Wizard.framework/Wizard", 2);
    void *h2 = dlopen("@executable_path/wizardcrackv2.dylib", 2);

    if (h1 || h2) {
        // 2. إظهار رسالة تأكيد النجاح بعد تخطي الـ 10 ثواني الحرجة
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            UIWindow *activeWin = nil;
            if (@available(iOS 13.0, *)) {
                for (UIWindowScene *scene in (id)[UIApplication sharedApplication].connectedScenes) {
                    if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == 0) {
                        activeWin = scene.windows.firstObject;
                        break;
                    }
                }
            }
            if (!activeWin) activeWin = [UIApplication sharedApplication].windows.firstObject;

            if (activeWin.rootViewController) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Bypass" 
                                              message:@"Server Intercepted! ✅\nEnter any code to start." 
                                              preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [activeWin.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        });
    }
}