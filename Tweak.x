#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h> // لإضافة التحقق من المكتبة

extern "C" void MSHookMessageEx(Class _class, SEL sel, IMP imp, IMP *result);

// وظيفة تخطي حماية ARC لضمان نجاح البناء (حل صورة 1163)
static IMP imp_from_block(id block) {
    return imp_implementationWithBlock(block);
}

%ctor {
    Class wizardCls = objc_getClass("Wizard");
    
    // التحقق هل المكتبة القديمة مرتبطة فعلاً؟
    BOOL isLibraryLinked = (dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOLOAD) != NULL);

    if (wizardCls) {
        // تفعيل الباسورد والـ VIP
        MSHookMessageEx(wizardCls, @selector(checkKey:), imp_from_block(^BOOL(id self, SEL _cmd, NSString *input) {
            return [input isEqualToString:@"12345"];
        }), NULL);

        class_replaceMethod(wizardCls, @selector(isKeyValid), imp_from_block(^BOOL(id self){ return YES; }), "B@:");
        class_replaceMethod(wizardCls, @selector(isVip), imp_from_block(^BOOL(id self){ return YES; }), "B@:");
    }

    // إظهار رسالة النجاح داخل اللعبة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindowScene *scene = (UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject];
        if (scene && scene.windows.count > 0) {
            NSString *statusMsg = isLibraryLinked ? @"Linked Successfully ✅" : @"Linked with Errors ⚠️";
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Wizard" 
                                          message:[NSString stringWithFormat:@"DooN UP Status: %@\nPass: 12345", statusMsg] 
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [scene.windows.firstObject.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}