#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

// وظيفة لإظهار تنبيه في أي وقت
void showDoonAlert(NSString *title, NSString *message) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindowScene *scene = (UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject];
        if (scene && scene.windows.count > 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title 
                                          message:message 
                                          preferredStyle:1];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:0 handler:nil]];
            [scene.windows.firstObject.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

// الكود اللي هيتنفذ أول ما اللعبة تفتح
__attribute__((constructor)) static void initDooN() {
    // رسالة تأكيد الحقن
    showDoonAlert(@"DooN UP", @"Tweak Loaded Successfully! ✅");

    // محاولة فتح المكتبة القديمة من "الجذر" مباشرة
    // جربنا المسار المباشر اللي قولت عليه
    void *handle = dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);
    
    // لو منفعش، نجرب بالاسم بس لأنها في الجذر
    if (!handle) handle = dlopen("wizardcrackv2.dylib", RTLD_NOW);

    // استكمال التعديل بعد 4 ثواني لضمان تحميل اللعبة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        Class wizardCls = objc_getClass("Wizard");
        
        if (wizardCls) {
            // تفعيل الباسورد والـ VIP
            class_replaceMethod(wizardCls, @selector(checkKey:), imp_implementationWithBlock(^BOOL(id self, SEL _cmd, NSString *input) {
                return [input isEqualToString:@"12345"];
            }), "B@:@");

            class_replaceMethod(wizardCls, @selector(isKeyValid), imp_implementationWithBlock(^BOOL(id self){ return YES; }), "B@:");
            class_replaceMethod(wizardCls, @selector(isVip), imp_implementationWithBlock(^BOOL(id self){ return YES; }), "B@:");
            
            showDoonAlert(@"DooN Wizard", @"Hack Activated! ✅\nPass: 12345");
        } else {
            showDoonAlert(@"DooN Error", @"Could not find 'Wizard' class. ❌");
        }
    });
}