#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <dlfcn.h>
#import <substrate.h>
#import <sys/stat.h>
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

// --- [1] استيراد كافة رموز المكتبة حرفياً كما في النسخ السابقة ---
extern "C" {
    void _ZN6Wizard8Security11VerifyLocalEv();
    void _ZN6Wizard8Security13BypassLicenseEPKc(const char* key);
    void _ZN6Wizard8Security14SetPremiumModeEb(bool enabled);
    void _ZN6Wizard8Security15VerifySignatureEv();
    void _ZN6Wizard8Security11ForceSignedEb(bool en);
    void _ZN6Wizard8Security13SpoofAppStoreEv();
    void _ZN6Wizard8Security9FakeTokenEv();
    void _ZN6Wizard8Security15ClearDeviceIdentityEv();
    void _ZN6Wizard4Pool15EnableGuidelineEb(bool enable);
    void _ZN6Wizard4Pool11LongLineModEb(bool enable);
    void _ZN6Wizard4Pool16PredictCollisionEv();
    void _ZN6Wizard4Pool12ForceDrawRayEv();
    void _ZN6Wizard4Pool10SetCuePowerEf(float power);
    void _ZN6Wizard4Pool13ShowTableGridEb(bool enable);
    void _ZN6Wizard4Pool8AutoShotEv();
    void _ZN6Wizard4Pool10AutoQueueEv();
    void _ZN6Wizard8Security22KillSecurityThreadsEv();
    void _ZN6Wizard8Security12EnableStealthEb(bool enabled);
    void _ZN6Wizard8Security18DisableIntegrityEv();
    void _ZN6Wizard8Security15SpoofDeviceGUIDEv();
    void _ZN6Wizard6Memory11RemapRegionEPvm(void* addr, size_t size);
    void _ZN6Wizard6Memory10WriteValueEmPvm(uintptr_t addr, void* val, size_t size);
    void _ZN6Wizard4Core11PatchStaticEv();
    void _ZN6Wizard4Core7ShieldEv();
    void _ZN6Wizard6Bridge18InitializeRuntimeEv();
    void _ZN6Wizard4Data15PushOffsetTableEv();
    void _ZN6Wizard8Security14ValidateBinaryEv(); 
    CFStringRef _ZN6Wizard8Security10GetFileMD5Ev();
    bool _ZN6Wizard8Security11IsConnectedEv();
}

// --- [2] نظام الهوكات العميقة (Stealth & Anti-Detection) ---

static CFStringRef (*old_GetFileMD5)();
CFStringRef new_GetFileMD5() {
    return CFSTR("e99a18c428cb38d5f260853678922e03"); 
}

static int (*old_stat)(const char *path, struct stat *buf);
int new_stat(const char *path, struct stat *buf) {
    if (path && (strstr(path, "MobileSubstrate") || strstr(path, "Tweak") || strstr(path, "MirrorLib"))) {
        errno = ENOENT;
        return -1;
    }
    return old_stat(path, buf);
}

bool new_IsConnected() { return true; }

// --- [3] السيرفر الإمبراطوري المتزامن ---
static void start_mirror_auth_server() {
    GCDWebServer* _webServer = [[GCDWebServer alloc] init];
    [_webServer addDefaultHandlerForMethod:@"GET" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
        NSDictionary* responseData = @{
            @"status": @"active",
            @"license_key": @"WIZ-PRO-MIRROR-2026",
            @"timestamp": [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]],
            @"user_info": @{ @"username": @"Wizard_Master", @"membership": @"Lifetime_Pro" },
            @"permissions": @{ @"guideline_unlimited": @YES, @"auto_play": @YES, @"anti_ban_v3": @YES, @"bypass_security": @YES },
            @"config": @{ @"server_version": @"2.5.0", @"heartbeat": @30 }
        };
        GCDWebServerDataResponse* res = [GCDWebServerDataResponse responseWithJSONObject:responseData];
        [res setValue:@"application/json" forAdditionalHeader:@"Content-Type"];
        [res setValue:@"v2-wizard-signed-protocol" forAdditionalHeader:@"X-Wizard-Auth"];
        return res;
    }];
    [_webServer startWithPort:8080 bonjourName:nil];
}

// --- [4] إصلاح الذاكرة (Memory Patches) ---
void run_internal_stabilizer() {
    uintptr_t slide = _dyld_get_image_vmaddr_slide(0);
    uint32_t patch_nop = 0xD503201F; 
    unsigned long offsets[] = {0x1023A45C, 0x1023A460, 0x1023B110, 0x1055C124, 0x1044D218};
    for (int i=0; i<5; i++) {
        void* target = (void*)(slide + offsets[i]);
        vm_protect(mach_task_self(), (vm_address_t)target, 4, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
        _ZN6Wizard6Memory11RemapRegionEPvm(target, 4);
        _ZN6Wizard6Memory10WriteValueEmPvm((uintptr_t)target, &patch_nop, 4);
        vm_protect(mach_task_self(), (vm_address_t)target, 4, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

// --- [5] المحرك التشغيلي للمكتبة (Constructor) ---
__attribute__((constructor))
static void mirror_library_entry() {
    @autoreleasepool {
        // تشغيل السيرفر فوراً
        start_mirror_auth_server();

        // محاكاة تأخير التحميل لضمان استقرار dylib الأصلي
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            void* handle = dlopen("/Library/MobileSubstrate/DynamicLibraries/wizardcrackv2.dylib", RTLD_NOW);
            if (handle) {
                // تطبيق الهوكات الأمنية
                MSHookFunction((void*)dlsym(RTLD_DEFAULT, "stat"), (void*)new_stat, (void**)&old_stat);
                MSHookFunction((void*)_ZN6Wizard8Security10GetFileMD5Ev, (void*)new_GetFileMD5, (void**)&old_GetFileMD5);
                MSHookFunction((void*)_ZN6Wizard8Security11IsConnectedEv, (void*)new_IsConnected, NULL);
                MSHookFunction((void*)_ZN6Wizard8Security14ValidateBinaryEv, (void*)NULL, NULL);

                // تهيئة البيانات
                _ZN6Wizard4Data15PushOffsetTableEv();
                _ZN6Wizard6Bridge18InitializeRuntimeEv();

                // تزييف الهوية والكراك
                _ZN6Wizard8Security15ClearDeviceIdentityEv();
                _ZN6Wizard8Security15SpoofDeviceGUIDEv();
                _ZN6Wizard8Security13SpoofAppStoreEv();
                _ZN6Wizard8Security13BypassLicenseEPKc("WIZ-MASTER-MIRROR-2026");
                _ZN6Wizard8Security14SetPremiumModeEb(true);
                _ZN6Wizard8Security11ForceSignedEb(true);
                _ZN6Wizard8Security15VerifySignatureEv();
                _ZN6Wizard8Security9FakeTokenEv();
                _ZN6Wizard8Security11VerifyLocalEv();

                // تفعيل كافة المميزات (التي طلبتها في الكود الأصلي)
                _ZN6Wizard4Pool15EnableGuidelineEb(true);
                _ZN6Wizard4Pool11LongLineModEb(true);
                _ZN6Wizard4Pool16PredictCollisionEv();
                _ZN6Wizard4Pool12ForceDrawRayEv();
                _ZN6Wizard4Pool8AutoShotEv();
                _ZN6Wizard4Pool10AutoQueueEv();
                
                // الحماية والباتشات
                _ZN6Wizard8Security22KillSecurityThreadsEv();
                _ZN6Wizard8Security18DisableIntegrityEv();
                _ZN6Wizard8Security12EnableStealthEb(true);
                _ZN6Wizard4Core11PatchStaticEv();
                _ZN6Wizard4Core7ShieldEv();
                run_internal_stabilizer();

                // إرسال الإشعارات
                [[NSNotificationCenter defaultCenter] postNotificationName:@"WizardSecurityPassedNotification" object:nil];
                
                NSLog(@"[MirrorLib] Success: All features and security patches injected into the target dylib.");
            }
        });
    }
}
