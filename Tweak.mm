#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

void doonUltimateFinalPatch() {
    // 1. تعديل النصوص في الواجهة (الاسم والتاريخ)
    Method original = class_getInstanceMethod([UILabel class], @selector(setText:));
    if (original) {
        IMP originalImp = method_getImplementation(original);
        method_setImplementation(original, imp_implementationWithBlock(^(UILabel *self, NSString *text) {
            if (text) {
                // تغيير اسم الهاك
                if ([text containsString:@"PIXEL RAID"] || [text containsString:@"Pixel Raid"]) {
                    text = [text stringByReplacingOccurrencesOfString:@"PIXEL RAID" withString:@"DOON RAID"];
                    text = [text stringByReplacingOccurrencesOfString:@"Pixel Raid" withString:@"DooN Raid"];
                }
                // تغيير التاريخ لـ 2036
                if ([text containsString:@"Key expire"] || [text containsString:@"22.01.2026"]) {
                    text = @"Key expire: 01.01.2036 00:00 ✅";
                }
            }
            ((void (*)(id, SEL, NSString *))originalImp)(self, @selector(setText:), text);
        }));
    }

    // 2. كسر حماية الكلاسات (Pixel, Raid, Wizard)
    int numClasses = objc_getClassList(NULL, 0);
    Class *classes = (Class *)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);

    for (int i = 0; i < numClasses; i++) {
        NSString *name = [NSString stringWithUTF8String:class_getName(classes[i])];
        if ([name containsString:@"Pixel"] || [name containsString:@"Raid"] || [name containsString:@"Wizard"]) {
            unsigned int mCount;
            Method *methods = class_copyMethodList(classes[i], &mCount);
            for (unsigned int j = 0; j < mCount; j++) {
                NSString *selName = NSStringFromSelector(method_getName(methods[j])).lowercaseString;
                if ([selName containsString:@"expired"] || [selName containsString:@"device"] || [selName containsString:@"vip"]) {
                    class_replaceMethod(classes[i], method_getName(methods[j]), imp_implementationWithBlock(^BOOL(id self) {
                        return [selName containsString:@"expired"] ? NO : YES;
                    }), "B@:");
                }
            }
            free(methods);
        }
    }
    free(classes);
}

__attribute__((constructor)) static void initDoonLegacy() {
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        doonUltimateFinalPatch();
        
        // رسالة ترحيب باسمك الجديد
        UIWindowScene *scene = (UIWindowScene *)[[[UIApplication sharedApplication] connectedScenes] anyObject];
        UIWindow *window = scene.windows.firstObject;
        if (window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Raid iOS" 
                                          message:@"Welcome to your Custom Edition! 🚀\nEverything is Unlocked." 
                                          preferredStyle:1];
            [alert addAction:[UIAlertAction actionWithTitle:@"Start" style:0 handler:nil]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}