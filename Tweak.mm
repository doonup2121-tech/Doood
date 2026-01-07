#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach/mach.h>

// دالة منع الإغلاق (Patching exit)
void doonLockSystem() {
    void* exit_ptr = dlsym(RTLD_DEFAULT, "exit");
    if (exit_ptr) {
        uint32_t ret_inst = 0xD65F03C0; 
        mach_port_t task = mach_task_self();
        if (vm_protect(task, (vm_address_t)exit_ptr, 4, NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY) == KERN_SUCCESS) {
            memcpy(exit_ptr, &ret_inst, 4);
            vm_protect(task, (vm_address_t)exit_ptr, 4, NO, VM_PROT_READ | VM_PROT_EXECUTE);
        }
    }
}

__attribute__((constructor)) static void startDoonSystem() {
    // 1. تحميل الملفات
    dlopen("@executable_path/Frameworks/Wizard.framework/Wizard", RTLD_NOW);
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    // 2. تفعيل منع الإغلاق
    doonLockSystem();

    // 3. طريقة حديثة لإظهار الرسالة متوافقة مع iOS 13+ و iOS 18
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // البحث عن الـ Window النشطة بطريقة متوافقة مع الـ SceneDelegate
        UIWindow *activeWindow = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    for (UIWindow *window in scene.windows) {
                        if (window.isKeyWindow) {
                            activeWindow = window;
                            break;
                        }
                    }
                }
            }
        }
        
        // لو ملقاش Scene (إصدارات أقدم)، نستخدم الطريقة البديلة الآمنة
        if (!activeWindow) {
            activeWindow = [UIApplication sharedApplication].windows.firstObject;
        }

        UIViewController *root = activeWindow.rootViewController;
        if (root) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Raid" 
                                          message:@"Anti-Close: ACTIVE ✅\nBypass Engaged." 
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            // تصحيح الـ Style ليتوافق مع الـ Build Log اللي بعته
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" 
                                         style:UIAlertActionStyleDefault 
                                         handler:nil];
            
            [alert addAction:okAction];
            [root presentViewController:alert animated:YES completion:nil];
        }
    });
}