#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>

// دالة البحث والتبديل في الذاكرة (Hex Patching)
void doonHexBypass(const uint8_t *search, const uint8_t *replace, size_t len) {
    uintptr_t base = 0;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, "wizardcrackv2.dylib")) {
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
        
        // 1. تنفيذ اختراق الذاكرة (الاسم والتاريخ)
        const uint8_t oldDate[] = {0x32, 0x30, 0x32, 0x36};
        const uint8_t newDate[] = {0x32, 0x30, 0x33, 0x36};
        doonHexBypass(oldDate, newDate, 4);

        const uint8_t oldName[] = {0x50, 0x49, 0x58, 0x45, 0x4C, 0x20, 0x52, 0x41, 0x49, 0x44};
        const uint8_t newName[] = {0x44, 0x4F, 0x4F, 0x4E, 0x20, 0x20, 0x52, 0x41, 0x49, 0x44};
        doonHexBypass(oldName, newName, 10);

        // 2. إظهار التنبيه بطريقة الـ Selector (لتجنب أخطاء الـ Build)
        UIViewController *root = [UIApplication sharedApplication].windows.firstObject.rootViewController;
        if (root) {
            // إنشاء التنبيه بدون استخدام Enums مباشرة لمنع الخطأ
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Raid" 
                                          message:@"Bypass Active! ✅\nExpiry: 2036" 
                                          preferredStyle:(UIAlertControllerStyle)1];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Enjoy" 
                                                style:(UIAlertActionStyle)0 
                                                handler:nil];
            
            [alert addAction:action];
            [root presentViewController:alert animated:YES completion:nil];
        }
    });
}