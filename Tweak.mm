#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>

// دالة لإظهار تقرير العمليات النهائي
void showDoonOpsReport(NSString *report) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        if (window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Operations Log" 
                                          message:report 
                                          preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:nil]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

// دالة محاولة كسر حماية الخروج
BOOL tryExitBypass() {
    void* exit_ptr = dlsym(RTLD_DEFAULT, "exit");
    if (exit_ptr) {
        uint8_t patch[] = {0xC0, 0x03, 0x5F, 0xD6}; 
        if (vm_protect(mach_task_self(), (vm_address_t)exit_ptr, 4, NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY) == KERN_SUCCESS) {
            memcpy(exit_ptr, patch, 4);
            return YES;
        }
    }
    return NO;
}

// دالة محاولة تعديل الذاكرة وإرجاع حالة النجاح
int tryMemoryPatch() {
    uintptr_t base = 0;
    int successCount = 0;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (strstr(_dyld_get_image_name(i), "wizardcrackv2.dylib")) {
            base = _dyld_get_image_vmaddr_slide(i) + (uintptr_t)_dyld_get_image_header(i);
            break;
        }
    }
    if (base > 0) {
        const char* n1 = "PIXEL RAID"; 
        const char* d1 = "2026";
        for (uintptr_t addr = base; addr < base + 0x1000000; addr++) {
            if (memcmp((void *)addr, n1, 10) == 0) {
                vm_protect(mach_task_self(), addr, 10, NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
                memcpy((void *)addr, "DOON  RAID", 10);
                successCount++;
            }
            if (memcmp((void *)addr, d1, 4) == 0) {
                vm_protect(mach_task_self(), addr, 4, NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
                memcpy((void *)addr, "2036", 4);
                successCount++;
            }
        }
    }
    return successCount; // سيعيد عدد التعديلات الناجحة
}

__attribute__((constructor)) static void doonOperationManager() {
    // محاولة الحقن
    void* l1 = dlopen("@executable_path/Frameworks/Wizard.framework/Wizard", RTLD_NOW);
    void* l2 = dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSMutableString *opsLog = [NSMutableString stringWithString:@"DooN Executed Operations:\n\n"];
        
        // 1. تقرير حقن المكتبات
        if (l1 && l2) [opsLog appendString:@"✅ Library Injection: SUCCESS\n"];
        else [opsLog appendString:@"❌ Library Injection: FAILED\n"];
        
        // 2. تقرير كسر حماية الإغلاق (Bypass)
        if (tryExitBypass()) [opsLog appendString:@"✅ Force Open Bypass: SUCCESS\n"];
        else [opsLog appendString:@"❌ Force Open Bypass: FAILED\n"];
        
        // 3. تقرير تعديل البيانات (الاسم والتاريخ)
        int patches = tryMemoryPatch();
        if (patches > 0) [opsLog appendString:[NSString stringWithFormat:@"✅ Memory Patching: SUCCESS (%d found)\n", patches]];
        else [opsLog appendString:@"❌ Memory Patching: FAILED (Strings not found)\n"];

        // عرض التقرير النهائي للعمليات
        showDoonOpsReport(opsLog);
    });
}