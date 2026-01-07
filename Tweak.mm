#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach/mach.h>

// دالة التعطيل الآمنة
void safeDoonFreeze() {
    void* exit_ptr = dlsym(RTLD_DEFAULT, "exit");
    if (exit_ptr) {
        uint32_t ret_inst = 0xD65F03C0; 
        vm_address_t addr = (vm_address_t)exit_ptr;
        // تغيير الصلاحيات بلطف
        if (vm_protect(mach_task_self(), addr, 4, NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY) == KERN_SUCCESS) {
            memcpy((void*)addr, &ret_inst, 4);
            vm_protect(mach_task_self(), addr, 4, NO, VM_PROT_READ | VM_PROT_EXECUTE);
        }
    }
}

__attribute__((constructor)) static void doonHybrid() {
    // 1. تحميل صامت للمكتبات (بدون أي تعديل في البداية لضمان الفتح)
    dlopen("@executable_path/Frameworks/Wizard.framework/Wizard", RTLD_NOW);
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    // 2. انتظر 8 ثواني (اللحظة الحرجة قبل القفل) ثم جمد الـ Exit
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        safeDoonFreeze();
        
        // إظهار رسالة إننا نجحنا في "تثبيت" اللعبة
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
                    window = ((UIWindowScene *)scene).windows.firstObject; break;
                }
            }
        }
        if (!window) window = [UIApplication sharedApplication].windows.firstObject;
        
        if (window && window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Raid" 
                                          message:@"Bypass Engaged! 🛡️\nExit Disabled." 
                                          preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}