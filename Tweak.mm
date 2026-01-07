#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>

// دالة ذكية لتعديل الذاكرة "تسلل"
void patchSilent(uintptr_t addr, uint32_t instruction) {
    mach_port_t task = mach_task_self();
    if (vm_protect(task, (vm_address_t)addr, 4, NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY) == KERN_SUCCESS) {
        *(uint32_t *)addr = instruction;
        vm_protect(task, (vm_address_t)addr, 4, NO, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

__attribute__((constructor)) static void doonBypassOnly() {
    // 1. تحميل المكتبة الأساسية
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    // 2. الانتظار 12 ثانية (عشان نتفادى أي فحص حماية في البداية)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        uintptr_t base = 0;
        for (uint32_t i = 0; i < _dyld_image_count(); i++) {
            if (strstr(_dyld_get_image_name(i), "wizardcrackv2.dylib")) {
                base = (uintptr_t)_dyld_get_image_vmaddr_slide(i) + (uintptr_t)_dyld_get_image_header(i);
                break;
            }
        }

        if (base > 0) {
            // هنا بقى اللعب كله:
            // هنخلي أي دالة بتحاول تقفل اللعبة ترجع "Success"
            // هنعطل الدوال اللي بتعمل Terminate للتطبيق
            void* abort_ptr = dlsym(RTLD_DEFAULT, "abort");
            if (abort_ptr) {
                uint32_t ret_inst = 0xD65F03C0; // أمر return في ARM64
                patchSilent((uintptr_t)abort_ptr, ret_inst);
            }
            
            // إظهار رسالة بسيطة إننا جاهزين للتخطي
            NSLog(@"[DooN] Ready to Bypass. Try any code now.");
        }
    });
}