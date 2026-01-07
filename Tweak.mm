#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

// دالة حديثة لإظهار الرسائل وتعديل الواجهة متوافقة مع iOS 18.5
void applyDoonPatch() {
    dispatch_async(dispatch_get_main_queue(), ^{
        // تعديل أي نص يظهر في القائمة (صورة 1131)
        Method original = class_getInstanceMethod([UILabel class], @selector(setText:));
        IMP originalImp = method_getImplementation(original);
        
        method_setImplementation(original, imp_implementationWithBlock(^(UILabel *self, NSString *text) {
            // صيد سطر التاريخ "Key expire" وتغييره لـ 2036
            if ([text containsString:@"Key expire"] || [text containsString:@"22.01.2026"]) {
                text = @"Key expire: 01.01.2036 00:00 ✅";
            }
            ((void (*)(id, SEL, NSString *))originalImp)(self, @selector(setText:), text);
        }));

        // إظهار تنبيه النجاح بطريقة متوافقة
        UIWindowScene *scene = (UIWindowScene *)[[[UIApplication sharedApplication] connectedScenes] anyObject];
        UIWindow *window = scene.windows.firstObject;
        
        if (window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Edition" 
                                          message:@"Bypassed & Extended to 2036! 🚀" 
                                          preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Enjoy" style:UIAlertActionStyleDefault handler:nil]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

__attribute__((constructor)) static void startGlobalCrack() {
    // فتح المكتبة الأصلية
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    // تنفيذ التعديلات بعد 4 ثواني لضمان تحميل القائمة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        applyDoonPatch();
        
        // كسر حماية الـ VIP وربط الجهاز (HWID)
        Class cls = objc_getClass("Wizard"); // اسم الكلاس من الصورة
        if (cls) {
            class_replaceMethod(cls, @selector(isExpired), imp_implementationWithBlock(^BOOL(id self) { return NO; }), "B@:");
            class_replaceMethod(cls, @selector(checkDevice), imp_implementationWithBlock(^BOOL(id self) { return YES; }), "B@:");
            class_replaceMethod(cls, @selector(isVip), imp_implementationWithBlock(^BOOL(id self) { return YES; }), "B@:");
        }
    });
}