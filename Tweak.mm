#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>

// دالة البحث والتبديل الاحترافية في الذاكرة
void applyDoonUltimatePatch(const char* image_name, const uint8_t *search, const uint8_t *replace, size_t len) {
    uintptr_t base = 0;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strcasestr(name, image_name)) {
            base = (uintptr_t)_dyld_get_image_vmaddr_slide(i) + (uintptr_t)_dyld_get_image_header(i);
            break;
        }
    }
    
    if (base > 0) {
        // مسح الذاكرة بعمق (5MB) لضمان الوصول لبيانات Core و ImGui
        for (uintptr_t addr = base; addr < base + 0x500000; addr++) {
            if (memcmp((void *)addr, search, len) == 0) {
                vm_protect(mach_task_self(), (vm_address_t)addr, len, NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
                memcpy((void *)addr, replace, len);
            }
        }
    }
}

// دالة التنبيه والتشغيل
void showDoonAlert() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        if (window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN Raid System" 
                                          message:@"Bypass Successful! ✅\nCore Data Injected" 
                                          preferredStyle:(UIAlertControllerStyle)1];
            [alert addAction:[UIAlertAction actionWithTitle:@"Start Cheating" style:(UIAlertActionStyle)0 handler:nil]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

__attribute__((constructor)) static void doonInitialLaunch() {
    // 1. تحميل الفريمورك والمكتبة حسب المسارات الحساسة لحالة الأحرف
    dlopen("@executable_path/Frameworks/Wizard.framework/Wizard", RTLD_NOW);
    dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);
    
    // 2. تأخير التنفيذ 5 ثواني لضمان قراءة ملف wizardcore.dat من مجلد Core
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        showDoonAlert();
        
        // 3. بدء عملية التعديل المستمر في الذاكرة (Loop)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while(1) {
                // تعديل التاريخ 2026 -> 2036
                const uint8_t oldDate[] = {0x32, 0x30, 0x32, 0x36};
                const uint8_t newDate[] = {0x32, 0x30, 0x33, 0x36};
                applyDoonUltimatePatch("wizardcrackv2.dylib", oldDate, newDate, 4);

                // تغيير الاسم PIXEL RAID -> DOON  RAID
                const uint8_t oldName[] = {0x50, 0x49, 0x58, 0x45, 0x4C, 0x20, 0x52, 0x41, 0x49, 0x44};
                const uint8_t newName[] = {0x44, 0x4F, 0x4F, 0x4E, 0x20, 0x20, 0x52, 0x41, 0x49, 0x44};
                applyDoonUltimatePatch("wizardcrackv2.dylib", oldName, newName, 10);
                
                [NSThread sleepForTimeInterval:2.0]; // التكرار كل ثانيتين
            }
        });
    });
}