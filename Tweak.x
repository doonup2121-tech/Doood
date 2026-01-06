#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

// التعريف الصحيح المتوافق مع كل الأنظمة (حل صورة 1164)
#ifdef __cplusplus
extern "C" {
#endif
    void MSHookMessageEx(Class _class, SEL sel, IMP imp, IMP *result);
#ifdef __cplusplus
}
#endif

// وظيفة تحويل البلوكات لتخطي حماية ARC (حل صورة 1163)
static IMP imp_from_block(id block) {
    return imp_implementationWithBlock(block);
}

%ctor {
    Class wizardCls = objc_getClass("Wizard");
    
    // التحقق من وجود المكتبة القديمة في الذاكرة
    BOOL isLibraryLinked = (dlopen("wizardcrackv2.dylib", RTLD_NOW) != NULL || 
                            dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW) != NULL);

    if (wizardCls) {
        // تفعيل الباسورد 12345
        MSHookMessageEx(wizardCls, @selector(checkKey:), imp_from_block(^BOOL(id self, SEL _cmd, NSString *input) {
            return [input isEqualToString:@"12345"];
        }), NULL);

        // تخطي الـ VIP
        class_replaceMethod(wizardCls, @selector(isKeyValid), imp_from_block(^BOOL(id self){ return YES; }), "B@:");
        class_replaceMethod(wizardCls, @selector(isVip), imp_from_block(^BOOL(id self){ return YES; }), "B@:");
    }

    // إظهار رسالة DooN UP وعلامة الصح ✅
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindowScene *scene = (UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject];
        if (scene && scene.windows.count > 0) {
            // لو المكتبة اتربطت يكتب علامة صح
            NSString *checkMark = isLibraryLinked ? @"Linked Successfully ✅" : @"Ready to Use ✅";
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Wizard" 
                                          message:[NSString stringWithFormat:@"Status: %@\nPass: 12345", checkMark] 
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"Enjoy" style:UIAlertActionStyleDefault handler:nil]];
            [scene.windows.firstObject.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}