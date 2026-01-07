#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach/mach.h>

// دالة منع القفل باستخدام تقنية الـ Memory Patching
void doonLockExit() {
    void* exit_ptr = dlsym(RTLD_DEFAULT, "exit");
    if (exit_ptr) {
        uint32_t ret_inst = 0xD65F03C0; // ARM64 return
        mach_port_t task = mach_task_self();
        if (vm_protect(task, (vm_address_t)exit_ptr, 4, NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY) == KERN_SUCCESS) {
            memcpy(exit_ptr, &ret_inst, 4);
            vm_protect(task, (vm_address_t)exit_ptr, 4, NO, VM_PROT_READ | VM_PROT_EXECUTE);
        }
    }
}

__attribute__((constructor)) static void startDoonSystem() {
    // 1. تحميل الملفات فوراً
    dlopen("@executable_path/Frameworks/Wizard.framework/Wizard", RTLD_NOW);
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    // 2. تفعيل الحماية ضد الإغلاق فوراً
    doonLockExit();

    // 3. إظهار الرسالة بطريقة صحيحة برمجياً (لتجنب خطأ الـ Build)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (root) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Raid" 
                                          message:@"Anti-Close: ACTIVE ✅\nTry any code now." 
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" 
                                         style:UIAlertActionStyleDefault 
                                         handler:nil];
            
            [alert addAction:okAction];
            [root presentViewController:alert animated:YES completion:nil];
        }
    });
}