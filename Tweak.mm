#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

// دالة التعديل الآمنة
void applySafeDoonPatch() {
    // تعديل UILabel فقط (مستحيل يسبب كراش لأنه نظام iOS)
    Method setText = class_getInstanceMethod([UILabel class], @selector(setText:));
    if (setText) {
        IMP originalImp = method_getImplementation(setText);
        method_setImplementation(setText, imp_implementationWithBlock(^(UILabel *self, NSString *text) {
            if (text && text.length > 0) {
                if ([text.lowercaseString containsString:@"pixel"] || [text.lowercaseString containsString:@"raid"]) {
                    text = @"DOON RAID IOS ✅";
                }
                if ([text containsString:@"202"] || [text.lowercaseString containsString:@"expire"]) {
                    text = @"Key expire: 01.01.2036 00:00";
                }
            }
            ((void (*)(id, SEL, NSString *))originalImp)(self, @selector(setText:), text);
        }));
    }
}

__attribute__((constructor)) static void doonSafeLoader() {
    // تحميل المكتبة الأصلية
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    // الانتظار وقت طويل (10 ثواني) لضمان انتهاء الشاشة السوداء تماماً
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        applySafeDoonPatch();
        
        // محاولة كسر الحماية لكلاس "Wizard" فقط لأنه الأكثر استقراراً
        Class cls = objc_getClass("Wizard");
        if (cls) {
            SEL s1 = @selector(isExpired);
            if (class_getInstanceMethod(cls, s1)) {
                class_replaceMethod(cls, s1, imp_implementationWithBlock(^BOOL(id self) { return NO; }), "B@:");
            }
            SEL s2 = @selector(checkDevice);
            if (class_getInstanceMethod(cls, s2)) {
                class_replaceMethod(cls, s2, imp_implementationWithBlock(^BOOL(id self) { return YES; }), "B@:");
            }
        }
    });
}