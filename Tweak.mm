#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach/mach.h>

// دالة فورية لتعطيل أمر الخروج تماماً
void freezeExit() {
    void* exit_ptr = dlsym(RTLD_DEFAULT, "exit");
    if (exit_ptr) {
        // تعليمات برمجية تجبر الدالة على العودة فوراً دون تنفيذ الخروج
        uint32_t ret_inst = 0xD65F03C0; 
        mach_port_t task = mach_task_self();
        vm_protect(task, (vm_address_t)exit_ptr, 4, NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
        memcpy(exit_ptr, &ret_inst, 4);
        vm_protect(task, (vm_address_t)exit_ptr, 4, NO, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

__attribute__((constructor)) static void doonStrike() {
    // 1. تجميد دالة الخروج أولاً وقبل أي شيء
    freezeExit();

    // 2. تحميل المكتبات
    dlopen("@executable_path/Frameworks/Wizard.framework/Wizard", RTLD_NOW);
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    // 3. إظهار رسالة النجاح بعد 5 ثوانٍ فقط
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
                    window = ((UIWindowScene *)scene).windows.firstObject;
                    break;
                }
            }
        }
        if (!window) window = [UIApplication sharedApplication].windows.firstObject;

        if (window && window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Raid" 
                                          message:@"Anti-Exit: ACTIVE ✅\nTry any code now." 
                                          preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}