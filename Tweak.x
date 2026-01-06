#import <UIKit/UIKit.h>
#import <objc/runtime.h>

extern void MSHookMessageEx(Class _class, SEL sel, IMP imp, IMP *result);

%ctor {
    Class wizardCls = objc_getClass("Wizard");
    if (wizardCls) {
        // الإصلاح النهائي: إضافة (__bridge void *) لحل مشكلة صورة 1161
        MSHookMessageEx(wizardCls, @selector(checkKey:), (IMP)(__bridge void *)^BOOL(id self, SEL _cmd, NSString *input) {
            return [input isEqualToString:@"12345"];
        }, NULL);

        class_replaceMethod(wizardCls, @selector(isKeyValid), (IMP)(__bridge void *)^BOOL(id self){ return YES; }, "B@:");
        class_replaceMethod(wizardCls, @selector(isVip), (IMP)(__bridge void *)^BOOL(id self){ return YES; }, "B@:");
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindowScene *scene = (UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject];
        if (scene && scene.windows.count > 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                          message:@"Wizard Crack Linked!\nPass: 12345" 
                                          preferredStyle:1];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:0 handler:nil]];
            [scene.windows.firstObject.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}