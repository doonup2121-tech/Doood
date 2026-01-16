#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <dlfcn.h>
#import <substrate.h>
#import <sys/stat.h>

/* GCDWebServer - استخدام علامات التنصيص للمجلد المحلي */
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

// --- [0] تعريف أجسام الدوال (Definitions) المستخرجة من المكتبة حرفياً ---
// تم مطابقة هذه الأسماء مع الرموز (Symbols) الموجودة في wizardcrackv2.dylib
namespace Wizard {
    namespace Security {
        void VerifyLocalEv() { /* Implementation inside dylib */ }
        void BypassLicenseEPKc(const char* key) { }
        void SetPremiumModeEb(bool enabled) { }
        void VerifySignatureEv() { }
        void ForceSignedEb(bool en) { }
        void SpoofAppStoreEv() { }
        void FakeTokenEv() { }
        void ClearDeviceIdentityEv() { }
        void KillSecurityThreadsEv() { }
        void EnableStealthEb(bool enabled) { }
        void DisableIntegrityEv() { }
        void SpoofDeviceGUIDEv() { }
        void ValidateBinaryEv() { }
        CFStringRef GetFileMD5Ev() { return CFSTR("e99a18c428cb38d5f260853678922e03"); }
        bool IsConnectedEv() { return true; }
    }
    namespace Pool {
        void EnableGuidelineEb(bool enable) { }
        void LongLineModEb(bool enable) { }
        void PredictCollisionEv() { }
        void ForceDrawRayEv() { }
        void SetCuePowerEf(float power) { }
        void ShowTableGridEb(bool enable) { }
        void AutoShotEv() { }
        void AutoQueueEv() { }
    }
    namespace Memory {
        void RemapRegionEPvm(void* addr, size_t size) { }
        void WriteValueEmPvm(uintptr_t addr, void* val, size_t size) { }
    }
    namespace Core {
        void PatchStaticEv() { }
        void ShieldEv() { }
    }
    namespace Bridge {
        void InitializeRuntimeEv() { }
    }
    namespace Data {
        void PushOffsetTableEv() { }
    }
}

// --- [1] الربط مع الرموز الخارجية (Extern C) لضمان توافق الـ Linker ---
extern "C" {
    void _ZN6Wizard8Security11VerifyLocalEv() { Wizard::Security::VerifyLocalEv(); }
    void _ZN6Wizard8Security13BypassLicenseEPKc(const char* key) { Wizard::Security::BypassLicenseEPKc(key); }
    void _ZN6Wizard8Security14SetPremiumModeEb(bool enabled) { Wizard::Security::SetPremiumModeEb(enabled); }
    void _ZN6Wizard8Security15VerifySignatureEv() { Wizard::Security::VerifySignatureEv(); }
    void _ZN6Wizard8Security11ForceSignedEb(bool en) { Wizard::Security::ForceSignedEb(en); }
    void _ZN6Wizard8Security13SpoofAppStoreEv() { Wizard::Security::SpoofAppStoreEv(); }
    void _ZN6Wizard8Security9FakeTokenEv() { Wizard::Security::FakeTokenEv(); }
    void _ZN6Wizard8Security15ClearDeviceIdentityEv() { Wizard::Security::ClearDeviceIdentityEv(); }
    void _ZN6Wizard4Pool15EnableGuidelineEb(bool enable) { Wizard::Pool::EnableGuidelineEb(enable); }
    void _ZN6Wizard4Pool11LongLineModEb(bool enable) { Wizard::Pool::LongLineModEb(enable); }
    void _ZN6Wizard4Pool16PredictCollisionEv() { Wizard::Pool::PredictCollisionEv(); }
    void _ZN6Wizard4Pool12ForceDrawRayEv() { Wizard::Pool::ForceDrawRayEv(); }
    void _ZN6Wizard4Pool10AutoShotEv() { Wizard::Pool::AutoShotEv(); }
    void _ZN6Wizard4Pool10AutoQueueEv() { Wizard::Pool::AutoQueueEv(); }
    void _ZN6Wizard8Security22KillSecurityThreadsEv() { Wizard::Security::KillSecurityThreadsEv(); }
    void _ZN6Wizard8Security12EnableStealthEb(bool enabled) { Wizard::Security::EnableStealthEb(enabled); }
    void _ZN6Wizard8Security18DisableIntegrityEv() { Wizard::Security::DisableIntegrityEv(); }
    void _ZN6Wizard8Security15SpoofDeviceGUIDEv() { Wizard::Security::SpoofDeviceGUIDEv(); }
    void _ZN6Wizard6Memory11RemapRegionEPvm(void* addr, size_t size) { Wizard::Memory::RemapRegionEPvm(addr, size); }
    void _ZN6Wizard6Memory10WriteValueEmPvm(uintptr_t addr, void* val, size_t size) { Wizard::Memory::WriteValueEmPvm(addr, val, size); }
    void _ZN6Wizard4Core11PatchStaticEv() { Wizard::Core::PatchStaticEv(); }
    void _ZN6Wizard4Core7ShieldEv() { Wizard::Core::ShieldEv(); }
    void _ZN6Wizard6Bridge18InitializeRuntimeEv() { Wizard::Bridge::InitializeRuntimeEv(); }
    void _ZN6Wizard4Data15PushOffsetTableEv() { Wizard::Data::PushOffsetTableEv(); }
    void _ZN6Wizard8Security14ValidateBinaryEv() { Wizard::Security::ValidateBinaryEv(); }
    CFStringRef _ZN6Wizard8Security10GetFileMD5Ev() { return Wizard::Security::GetFileMD5Ev(); }
    bool _ZN6Wizard8Security11IsConnectedEv() { return Wizard::Security::IsConnectedEv(); }
}

// --- [2] نظام الهوكات العميقة ---
static CFStringRef (*old_GetFileMD5)();
CFStringRef new_GetFileMD5() { return CFSTR("e99a18c428cb38d5f260853678922e03"); }

static int (*old_stat)(const char *path, struct stat *buf);
int new_stat(const char *path, struct stat *buf) {
    if (path && (strstr(path, "MobileSubstrate") || strstr(path, "Tweak") || strstr(path, "MirrorLib"))) {
        errno = ENOENT; return -1;
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
            @"user_info": @{ @"username": @"Wizard_Master" },
            @"permissions": @{ @"bypass_security": @YES }
        };
        return [GCDWebServerDataResponse responseWithJSONObject:responseData];
    }];
    [_webServer startWithPort:8080 bonjourName:nil];
}

// --- [4] إصلاح الذاكرة ---
void run_internal_stabilizer() {
    uintptr_t slide = _dyld_get_image_vmaddr_slide(0);
    uint32_t patch_nop = 0xD503201F; 
    unsigned long offsets[] = {0x1023A45C, 0x1023A460, 0x1023B110, 0x1055C124, 0x1044D218};
    for (int i=0; i<5; i++) {
        void* target = (void*)(slide + offsets[i]);
        vm_protect(mach_task_self(), (vm_address_t)target, 4, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
        _ZN6Wizard6Memory10WriteValueEmPvm((uintptr_t)target, &patch_nop, 4);
        vm_protect(mach_task_self(), (vm_address_t)target, 4, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

// --- [5] Constructor ---
__attribute__((constructor))
static void mirror_library_entry() {
    @autoreleasepool {
        start_mirror_auth_server();
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            void* handle = dlopen("/Library/MobileSubstrate/DynamicLibraries/wizardcrackv2.dylib", RTLD_NOW);
            if (handle) {
                MSHookFunction((void*)dlsym(RTLD_DEFAULT, "stat"), (void*)new_stat, (void**)&old_stat);
                MSHookFunction((void*)_ZN6Wizard8Security10GetFileMD5Ev, (void*)new_GetFileMD5, (void**)&old_GetFileMD5);
                MSHookFunction((void*)_ZN6Wizard8Security11IsConnectedEv, (void*)new_IsConnected, NULL);

                _ZN6Wizard4Data15PushOffsetTableEv();
                _ZN6Wizard6Bridge18InitializeRuntimeEv();
                _ZN6Wizard8Security13BypassLicenseEPKc("WIZ-MASTER-MIRROR-2026");
                _ZN6Wizard4Pool15EnableGuidelineEb(true);
                _ZN6Wizard8Security22KillSecurityThreadsEv();
                run_internal_stabilizer();

                [[NSNotificationCenter defaultCenter] postNotificationName:@"WizardSecurityPassedNotification" object:nil];
                NSLog(@"[MirrorLib] Fully Injected using Extracted Symbols.");
            }
        });
    }
}
