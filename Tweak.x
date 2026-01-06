#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// تعريف الدالة المفقودة للهرب من خطأ undeclared function (الصورة IMG_1143)
extern void MSHookMessageEx(Class _class, SEL sel, IMP imp, IMP *result);

// دالة حساب تاريخ الصلاحية (شهر من الآن)
static long long getDooNExpiry() {
    return (long long)[[NSDate date] timeIntervalSince1970] + (30 * 24 * 60 * 60);
}

%ctor {
    // استهداف الكلاس من المكتبة القديمة wizardcrackv2
    Class wizardCls = objc_getClass("Wizard");
    
    if (wizardCls) {
        // الـ Hook الخاص بكلمة السر 12345
        // أضفنا (void *) قبل الـ Block لحل مشكلة "disallowed with ARC" (الصورة IMG_1142)
        MSHookMessageEx(wizardCls, @selector(checkKey:), (IMP)(void *)^BOOL(id self, SEL _cmd, NSString *input) {
            return [input isEqualToString:@"12345"];
        }, NULL);

        // تفعيل الـ VIP والصلاحية الدائمة
        class_replaceMethod(wizardCls, @selector(isKeyValid), (IMP)(void *)^BOOL(id self){ return YES; }, "B@:");
        class_replaceMethod(wizardCls, @selector(isVip), (IMP)(void *)^BOOL(id self){ return YES; }, "B@:");
        
        // ربط التاريخ بالدالة الجديدة
        class_replaceMethod(wizardCls, @selector(getExpiryDate), (IMP)getDooNExpiry, "q@:");
    }

    // إظهار رسالة DooN UP عند تشغيل اللعبة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindowScene *scene = (UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject];
        if (scene && scene.windows.count > 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN UP ✅" 
                                          message:@"Wizard Crack Linked Successfully!\nPassword: 12345" 
                                          preferredStyle:1];
            [alert addAction:[UIAlertAction actionWithTitle:@"Enjoy" style:0 handler:nil]];
            [scene.windows.firstObject.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}