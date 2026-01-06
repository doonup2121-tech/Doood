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
    Class wizardCls = objc_getClass("Wizard");
    // التحقق من ربط المكتبة القديمة ✅
    void *handle = dlopen("wizardcrackv2.dylib", RTLD_NOW);
    if (!handle) handle = dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    if (wizardCls) {
        MSHookMessageEx(wizardCls, @selector(checkKey:), imp_from_block(^BOOL(id self, SEL _cmd, NSString *input) {
            return [input isEqualToString:@"12345"];
        }), NULL);

        class_replaceMethod(wizardCls, @selector(isKeyValid), imp_from_block(^BOOL(id self){ return YES; }), "B@:");
        class_replaceMethod(wizardCls, @selector(isVip), imp_from_block(^BOOL(id self){ return YES; }), "B@:");
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindowScene *scene = (UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject];
        if (scene && scene.windows.count > 0) {
            NSString *msg = (handle != NULL) ? @"Linked Successfully ✅" : @"Modded Successfully ✅";
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Wizard" 
                                          message:[NSString stringWithFormat:@"%@\nPass: 12345", msg] 
                                          preferredStyle:1];
            [alert addAction:[UIAlertAction actionWithTitle:@"Enjoy" style:0 handler:nil]];
            [scene.windows.firstObject.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}