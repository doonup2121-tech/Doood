#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

// دالة تعديل النصوص (الاسم والتاريخ) متوافقة مع iOS 18.5
void applyDoonBranding() {
    Method original = class_getInstanceMethod([UILabel class], @selector(setText:));
    if (!original) return;
    
    IMP originalImp = method_getImplementation(original);
    method_setImplementation(original, imp_implementationWithBlock(^(UILabel *self, NSString *text) {
        if (text) {
            // 1. تغيير اسم الهاك في القائمة
            if ([text.lowercaseString containsString:@"pixel raid"]) {
                text = @"DOON RAID IOS ✅";
            }
            // 2. تغيير تاريخ الانتهاء لـ 2036
            if ([text containsString:@"202"] || [text containsString:@"Key expire"]) {
                text = @"Key expire: 01.01.2036 00:00";
            }
        }
        ((void (*)(id, SEL, NSString *))originalImp)(self, @selector(setText:), text);
    }));
}

__attribute__((constructor)) static void doonGlobalLaunch() {
    // فتح المكتبة الأصلية
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    // تنفيذ التعديلات بعد 5 ثوانٍ لضمان ظهور القائمة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        applyDoonBranding();

        // كسر الحماية داخلياً لأي كلاس (Pixel/Raid/Wizard)
        int numClasses = objc_getClassList(NULL, 0);
        Class *classes = (Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);

        for (int i = 0; i < numClasses; i++) {
            NSString *name = [NSString stringWithUTF8String:class_getName(classes[i])];
            if ([name containsString:@"Pixel"] || [name containsString:@"Raid"] || [name containsString:@"Wizard"]) {
                unsigned int mCount;
                Method *methods = class_copyMethodList(classes[i], &mCount);
                for (unsigned int j = 0; j < mCount; j++) {
                    SEL s = method_getName(methods[j]);
                    NSString *sName = NSStringFromSelector(s).lowercaseString;
                    if ([sName containsString:@"expired"] || [sName containsString:@"vip"] || [sName containsString:@"device"]) {
                        class_replaceMethod(classes[i], s, imp_implementationWithBlock(^BOOL(id self) {
                            return [sName containsString:@"expired"] ? NO : YES;
                        }), "B@:");
                    }
                }
                free(methods);
            }
        }
        free(classes);
    });
}