#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>

// دالة البحث عن البصمة الرقمية وتبديلها في الذاكرة الحية
void doonHexBypass(const uint8_t *search, const uint8_t *replace, size_t len) {
    uintptr_t base = 0;
    // تحديد مكان مكتبة الكراك في الرام
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (strstr(_dyld_get_image_name(i), "wizardcrackv2.dylib")) {
            base = _dyld_get_image_vmaddr_slide(i) + (uintptr_t)_dyld_get_image_header(i);
            break;
        }
    }

    if (base > 0) {
        // مسح مساحة 2 ميجا من المكتبة (المنطقة اللي فيها النصوص)
        for (uintptr_t addr = base; addr < base + 0x200000; addr++) {
            if (memcmp((void *)addr, search, len) == 0) {
                // فك حماية الذاكرة للكتابة
                vm_protect(mach_task_self(), (vm_address_t)addr, len, NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
                memcpy((void *)addr, replace, len);
            }
        }
    }
}

__attribute__((constructor)) static void doonFinalStrike() {
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    // الانتظار 4 ثواني لضمان فك ضغط المكتبة في الرام
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 1. تبديل تاريخ 2026 لـ 2036 (Hex Pattern)
        const uint8_t oldDate[] = {0x32, 0x30, 0x32, 0x36};
        const uint8_t newDate[] = {0x32, 0x30, 0x33, 0x36};
        doonHexBypass(oldDate, newDate, 4);

        // 2. تبديل PIXEL RAID لـ DOON RAID (Hex Pattern)
        const uint8_t oldName[] = {0x50, 0x49, 0x58, 0x45, 0x4C, 0x20, 0x52, 0x41, 0x49, 0x44};
        const uint8_t newName[] = {0x44, 0x4F, 0x4F, 0x4E, 0x20, 0x20, 0x52, 0x41, 0x49, 0x44};
        doonHexBypass(oldName, newName, 10);
        
        // 3. إظهار رسالة DooN لإثبات السيطرة
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        if (window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Raid" 
                                          message:@"Memory Hex Patched! ✅\nExpiry: 2036\nStatus: Activated" 
                                          preferredStyle:1];
            [alert addAction:[UIAlertAction actionWithTitle:@"GO" style:0 handler:nil]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}