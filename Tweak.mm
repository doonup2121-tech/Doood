#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

__attribute__((constructor)) static void doonTimeGlitch() {
    // فتح مكتبة الهاك الأساسية
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 1. تزييف أي نص يظهر في القائمة (UI Label)
        // بنعدل دالة setText في نظام الـ iOS نفسه عشان نصيد أي تاريخ طالع للواجهة
        Method targetMethod = class_getInstanceMethod([UILabel class], @selector(setText:));
        IMP originalImp = method_getImplementation(targetMethod);
        
        method_setImplementation(targetMethod, imp_implementationWithBlock(^(UILabel *self, NSString *text) {
            // لو النص فيه نقط (شبه التاريخ) أو كلمة Expire أو Valid
            if ([text containsString:@"."] && text.length > 8) {
                text = @"Expiry: 01.01.2036 ✅"; // التاريخ الجديد بتاعك
            }
            
            // استدعاء الدالة الأصلية عشان تعرض النص المعدل
            ((void (*)(id, SEL, NSString *))originalImp)(self, @selector(setText:), text);
        }));

        // 2. ضمان إن الهاك يفضل شغال داخلياً (حتى لو التاريخ خلص)
        Class cls = objc_getClass("Wizard");
        if (cls) {
            // إجبار دوال التحقق على إعطاء نتيجة إيجابية دائماً
            SEL selectors[] = {@selector(isExpired), @selector(checkDevice), @selector(isVip)};
            for (int i = 0; i < 3; i++) {
                if (class_getInstanceMethod(cls, selectors[i])) {
                    class_replaceMethod(cls, selectors[i], imp_implementationWithBlock(^BOOL(id self) {
                        return (i == 0) ? NO : YES; // Expired = NO, Others = YES
                    }), "B@:");
                }
            }
        }

        // رسالة تأكيد النجاح
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Mode" 
                                      message:@"Visuals Patched & Time Frozen! 🚀" 
                                      preferredStyle:1];
        [alert addAction:[UIAlertAction actionWithTitle:@"Legendary" style:0 handler:nil]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}