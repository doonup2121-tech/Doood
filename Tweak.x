#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

// حل مشكلة الـ ARC والـ Symbols
static IMP imp_from_block(id block) {
    return imp_implementationWithBlock(block);
}

// دالة لإظهار تنبيه بسيط للتأكد من أن الهاك يعمل
void showDoonAlert(NSString *msg) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindowScene *scene = (UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject];
        if (scene && scene.windows.count > 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP" 
                                          message:msg 
                                          preferredStyle:1];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:0 handler:nil]];
            [scene.windows.firstObject.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

%ctor {
    // أولاً: رسالة فورية للتأكد أن التويك "عايش"
    // لو الرسالة دي ظهرت، يبقى المشكلة في الكود. لو مظهرتش، يبقى المشكلة في الدمج.
    showDoonAlert(@"Tweak Loaded! Starting Hack... ✅");

    // محاولة الوصول للكلاس مباشرة (بدون انتظار dlfcn)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        Class wizardCls = objc_getClass("Wizard");
        
        if (wizardCls) {
            // تفعيل الباسورد 12345 باستخدام Runtime فقط (أضمن في الـ IPA)
            SEL sel = @selector(checkKey:);
            Method method = class_getInstanceMethod(wizardCls, sel);
            if (method) {
                class_replaceMethod(wizardCls, sel, imp_from_block(^BOOL(id self, SEL _cmd, NSString *input) {
                    return [input isEqualToString:@"12345"];
                }), method_getTypeEncoding(method));
            }

            // تفعيل الـ VIP
            class_replaceMethod(wizardCls, @selector(isKeyValid), imp_from_block(^BOOL(id self){ return YES; }), "B@:");
            class_replaceMethod(wizardCls, @selector(isVip), imp_from_block(^BOOL(id self){ return YES; }), "B@:");
            
            showDoonAlert(@"Wizard Modded Successfully! ✅\nPass: 12345");
        } else {
            showDoonAlert(@"Error: 'Wizard' class not found! ❌");
        }
    });
}