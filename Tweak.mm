#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

// دالة حديثة لإظهار الرسائل وتعديل الواجهة بدون keyWindow
void doonPublicPatch(NSString *newDate) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *win = nil;
        for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                win = scene.windows.firstObject; break;
            }
        }
        
        // تعديل أي نص (Label) يحتوي على تاريخ ليصبح 2036
        Method original = class_getInstanceMethod([UILabel class], @selector(setText:));
        IMP originalImp = method_getImplementation(original);
        method_setImplementation(original, imp_implementationWithBlock(^(UILabel *self, NSString *text) {
            if ([text containsString:@"202"]) { // صيد أي تاريخ يبدأ بـ 202
                text = newDate; 
            }
            ((void (*)(id, SEL, NSString *))originalImp)(self, @selector(setText:), text);
        }));
        
        if (win.rootViewController) {
            UIAlertController *a = [UIAlertController alertControllerWithTitle:@"DooN Unlocked" message:@"Public Version: Activated Forever! ✅" preferredStyle:1];
            [a addAction:[UIAlertAction actionWithTitle:@"Enjoy" style:0 handler:nil]];
            [win.rootViewController presentViewController:a animated:YES completion:nil];
        }
    });
}

__attribute__((constructor)) static void initDoonEngine() {
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        doonPublicPatch(@"Key expire: 01.01.2036 13:15");
        
        Class cls = objc_getClass("Wizard");
        if (cls) {
            // كسر الحماية للأبد ولأي جهاز
            IMP yes = imp_implementationWithBlock(^BOOL(id s){ return YES; });
            IMP no = imp_implementationWithBlock(^BOOL(id s){ return NO; });
            
            class_replaceMethod(cls, @selector(isExpired), no, "B@:");
            class_replaceMethod(cls, @selector(checkDevice), yes, "B@:");
            class_replaceMethod(cls, @selector(isVip), yes, "B@:");
        }
    });
}