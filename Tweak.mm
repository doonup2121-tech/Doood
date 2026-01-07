#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>

// دالة البحث والتبديل في الذاكرة الحية (Hex Patching)
void doonHexBypass(const uint8_t *search, const uint8_t *replace, size_t len) {
    uintptr_t base = 0;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (strstr(_dyld_get_image_name(i), "wizardcrackv2.dylib")) {
            base = (uintptr_t)_dyld_get_image_vmaddr_slide(i) + (uintptr_t)_dyld_get_image_header(i);
            break;
        }
    }

    if (base > 0) {
        for (uintptr_t addr = base; addr < base + 0x200000; addr++) {
            if (memcmp((void *)addr, search, len) == 0) {
                vm_protect(mach_task_self(), (vm_address_t)addr, len, NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
                memcpy((void *)addr, replace, len);
            }
        }
    }
}

__attribute__((constructor)) static void doonFinalStrike() {
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 1. تبديل التاريخ (2026 -> 2036)
        const uint8_t oldDate[] = {0x32, 0x30, 0x32, 0x36};
        const uint8_t newDate[] = {0x32, 0x30, 0x33, 0x36};
        doonHexBypass(oldDate, newDate, 4);

        // 2. تبديل الاسم (PIXEL RAID -> DOON  RAID)
        const uint8_t oldName[] = {0x50, 0x49, 0x58, 0x45, 0x4C, 0x20, 0x52, 0x41, 0x49, 0x44};
        const uint8_t newName[] = {0x44, 0x4F, 0x4F, 0x4E, 0x20, 0x20, 0x52, 0x41, 0x49, 0x44};
        doonHexBypass(oldName, newName, 10);
        
        // 3. رسالة التفعيل مع التصحيح (Casting)
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window.rootViewController) {
            // استخدام (UIAlertControllerStyle)1 و (UIAlertActionStyle)0 لحل مشكلة الـ Build
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN System" 
                                          message:@"Bypass Success! ✅\nAll Codes are Valid Until 2036" 
                                          preferredStyle:(UIAlertControllerStyle)1];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"Start" 
                                              style:(UIAlertActionStyle)0 
                                              handler:nil]];
            
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}