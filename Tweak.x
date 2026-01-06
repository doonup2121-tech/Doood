#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// تعريف المكتبة كـ C لضمان أن الـ Linker يراها (حل صورة 1162)
#ifdef __cplusplus
extern "C" {
#endif
    void MSHookMessageEx(Class _class, SEL sel, IMP imp, IMP *result);
#ifdef __cplusplus
}
#endif

%ctor {
    // تحليل المكتبة القديمة: استهداف كلاس Wizard
    Class wizardCls = objc_getClass("Wizard");
    
    if (wizardCls) {
        // 1. تفعيل الباسورد 12345
        MSHookMessageEx(wizardCls, @selector(checkKey:), (IMP)^BOOL(id self, SEL _cmd, NSString *input) {
            if ([input isEqualToString:@"12345"]) {
                return YES;
            }
            return NO;
        }, NULL);

        // 2. تخطي حماية الـ VIP (تحليل دقيق لوظائف المكتبة)
        class_replaceMethod(wizardCls, @selector(isKeyValid), (IMP)^BOOL(id self){ return YES; }, "B@:");
        class_replaceMethod(wizardCls, @selector(isVip), (IMP)^BOOL(id self){ return YES; }, "B@:");
    }

    // 3. إضافة لمسة DooN UP عند التشغيل
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindowScene *scene = (UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject];
        if (scene && scene.windows.count > 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                          message:@"Wizard Modded Successfully!\nPass: 12345" 
                                          preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Enjoy" style:UIAlertActionStyleDefault handler:nil]];
            [scene.windows.firstObject.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}