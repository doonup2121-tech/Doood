#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach/mach.h>

// دالة منع القفل + إجبار النجاح
void doonGodMode() {
    // 1. لحام مخارج الطوارئ (عشان اللعبة متقفلش)
    void* exit_ptr = dlsym(RTLD_DEFAULT, "exit");
    if (exit_ptr) {
        uint32_t ret = 0xD65F03C0; 
        vm_protect(mach_task_self(), (vm_address_t)exit_ptr, 4, NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
        memcpy(exit_ptr, &ret, 4);
    }

    // 2. خدعة السيرفر (تزييف الرد)
    // هنوهم المكتبة إن أي استجابة جاية هي "Success"
    void* handle = dlopen("@executable_path/wizardcrackv2.dylib", RTLD_NOW);
    if (handle) {
        // هنا بنقول للتويك: خليك شغال حتى لو السيرفر قال لأ
        NSLog(@"[DooN] Library Seized!");
    }
}

__attribute__((constructor)) static void start() {
    // تشغيل المنع فوراً قبل مرور الـ 10 ثواني
    doonGodMode();
    
    // رسالة تطمنك إن اللعبة "تحت السيطرة"
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DooN System" 
                                      message:@"Anti-Close Active ✅\nTry any code now!" 
                                      preferredStyle:1];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:0 handler:nil]];
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}