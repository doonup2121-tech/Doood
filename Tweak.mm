#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

// دالة التبديل الإجباري - لا تعتمد على أسماء الكلاسات
void forceDoonPatch() {
    // 1. سيطرة كاملة على نصوص الواجهة (الاسم والتاريخ)
    Method setText = class_getInstanceMethod([UILabel class], @selector(setText:));
    if (setText) {
        IMP originalImp = method_getImplementation(setText);
        method_setImplementation(setText, imp_implementationWithBlock(^(UILabel *self, NSString *text) {
            if (text && text.length > 0) {
                // تبديل اسم الهاك فوراً
                if ([text.lowercaseString containsString:@"pixel"] || [text.lowercaseString containsString:@"raid"]) {
                    text = @"DOON RAID IOS ✅";
                }
                // تبديل التاريخ فوراً لـ 2036
                if ([text containsString:@"202"] || [text.lowercaseString containsString:@"expire"]) {
                    text = @"Key expire: 01.01.2036 00:00";
                }
            }
            ((void (*)(id, SEL, NSString *))originalImp)(self, @selector(setText:), text);
        }));
    }

    // 2. كسر حماية الـ VIP والجهاز (البحث عن الوظائف بالمعنى وليس بالاسم)
    int numClasses = objc_getClassList(NULL, 0);
    Class *classes = (Class *)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);

    for (int i = 0; i < numClasses; i++) {
        unsigned int mCount;
        Method *methods = class_copyMethodList(classes[i], &mCount);
        for (unsigned int j = 0; j < mCount; j++) {
            NSString *selName = NSStringFromSelector(method_getName(methods[j])).lowercaseString;
            
            // أي دالة بترجع Bool وليها علاقة بالأمان هيتم تعديلها
            if ([selName containsString:@"expired"] || [selName containsString:@"device"] || [selName containsString:@"vip"]) {
                class_replaceMethod(classes[i], method_getName(methods[j]), imp_implementationWithBlock(^BOOL(id self) {
                    return [selName containsString:@"expired"] ? NO : YES;
                }), "B@:");
            }
        }
        free(methods);
    }
    free(classes);
}

// محرك التشغيل الأساسي
__attribute__((constructor)) static void loadDoon() {
    // تحميل مكتبة الهاك الأصلية أولاً
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    // تكرار محاولة الحقن كل ثانية لضمان النجاح بعد تحميل القائمة
    for (int t = 1; t <= 5; t++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(t * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            forceDoonPatch();
        });
    }
}