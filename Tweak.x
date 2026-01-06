#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

#ifdef __cplusplus
extern "C" {
#endif
    void MSHookMessageEx(Class _class, SEL sel, IMP imp, IMP *result);
#ifdef __cplusplus
}
#endif

static IMP imp_from_block(id block) {
    return imp_implementationWithBlock(block);
}

%ctor {
    // التحقق من المكتبة وهي موجودة أصلاً جوه اللعبة
    // جربنا أكتر من مسار عشان نضمن إنه يوصل لها
    void *handle = dlopen("wizardcrackv2.dylib", RTLD_NOW);
    if (!handle) handle = dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);
    if (!handle) handle = dlopen("@executable_path/Frameworks/wizardcrackv2.dylib", RTLD_NOW);

    Class wizardCls = objc_getClass("Wizard");

    if (wizardCls) {
        // تفعيل الباسورد
        MSHookMessageEx(wizardCls, @selector(checkKey:), imp_from_block(^BOOL(id self, SEL _cmd, NSString *input) {
            return [input isEqualToString:@"12345"];
        }), NULL);

        // تفعيل الـ VIP
        class_replaceMethod(wizardCls, @selector(isKeyValid), imp_from_block(^BOOL(id self){ return YES; }), "B@:");
        class_replaceMethod(wizardCls, @selector(isVip), imp_from_block(^BOOL(id self){ return YES; }), "B@:");
    }

    // إظهار علامة الصح ✅ لأن الربط تم داخلياً
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindowScene *scene = (UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject];
        if (scene && scene.windows.count > 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Wizard" 
                                          message:@"DooN UP Connected ✅\nPass: 12345" 
                                          preferredStyle:1];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:0 handler:nil]];
            [scene.windows.firstObject.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}