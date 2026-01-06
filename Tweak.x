#import <UIKit/UIKit.h>
#import <objc/runtime.h>

extern void MSHookMessageEx(Class _class, SEL sel, IMP imp, IMP *result);

static long long getTrialExpiry() {
    return (long long)[[NSDate date] timeIntervalSince1970] + (30 * 24 * 60 * 60);
}

%ctor {
    Class wizardCls = objc_getClass("Wizard");
    if (wizardCls) {
        MSHookMessageEx(wizardCls, @selector(checkKey:), (IMP)(void *)^BOOL(id self, SEL _cmd, NSString *input) {
            return [input isEqualToString:@"123456"];
        }, NULL);

        class_replaceMethod(wizardCls, @selector(isKeyValid), (IMP)(void *)^BOOL(id self){ return YES; }, "B@:");
        class_replaceMethod(wizardCls, @selector(isVip), (IMP)(void *)^BOOL(id self){ return YES; }, "B@:");
        class_replaceMethod(wizardCls, @selector(getExpiryDate), (IMP)getTrialExpiry, "q@:");
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindowScene *scene = (UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject];
        if (scene && scene.windows.count > 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                          message:@"Wizard Crack Linked!\nKey: 123456" 
                                          preferredStyle:1];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:0 handler:nil]];
            [scene.windows.firstObject.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}