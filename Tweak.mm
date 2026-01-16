#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <dlfcn.h>
#import <substrate.h>
#import <sys/stat.h>

/* GCDWebServer imports */
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

// --- [1] المحاكاة الكاملة للهيكل وفقاً للمكتبة القديمة ---
extern "C" {
    #define WIZ_FIX __attribute__((visibility("default"))) void
    #define WIZ_BOOL __attribute__((visibility("default"))) bool
    #define WIZ_CF __attribute__((visibility("default"))) CFStringRef

    // [تعديل أمان]: تنفيذ دالة WriteValue مع فحص النطاق لمنع الكراش اللحظي
    __attribute__((visibility("default"))) void _ZN6Wizard6Memory10WriteValueEmPvm(uintptr_t addr, void* val, size_t size) {
        // حماية: لو العنوان صفر أو في منطقة النظام المحمية (أقل من 0x100000000) لا تنفذ
        if (addr < 0x100000000 || !val) return; 
        
        mach_port_t task = mach_task_self();
        kern_return_t kr = vm_protect(task, (vm_address_t)addr, size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
        
        if (kr == KERN_SUCCESS) {
            memcpy((void*)addr, val, size);
            vm_protect(task, (vm_address_t)addr, size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
        }
    }

    // تنفيذ الدوال الأساسية لضمان عمل الـ Physics
    WIZ_FIX _ZN6Wizard4Pool11LongLineModEb(bool enable) {
        if (enable) {
            uintptr_t slide = _dyld_get_image_vmaddr_slide(0);
            uintptr_t target = slide + 0x1023A45C; 
            uint32_t patch = 0xD503201F; // NOP Instruction
            _ZN6Wizard6Memory10WriteValueEmPvm(target, &patch, 4);
        }
    }

    // دوال الحماية - تعيد قيم النجاح كما في الأصل
    WIZ_BOOL _ZN6Wizard8Security11IsConnectedEv() { return true; }
    WIZ_CF _ZN6Wizard8Security10GetFileMD5Ev() { return CFSTR("e99a18c428cb38d5f260853678922e03"); }
    WIZ_FIX _ZN6Wizard8Security14ValidateBinaryEv() {}
    WIZ_FIX _ZN6Wizard8Security18DisableIntegrityEv() {}
    WIZ_FIX _ZN6Wizard8Security22KillSecurityThreadsEv() {}
    WIZ_FIX _ZN6Wizard6Bridge18InitializeRuntimeEv() {}
    WIZ_FIX _ZN6Wizard4Data15PushOffsetTableEv() {}
    WIZ_FIX _ZN6Wizard4Core11PatchStaticEv() {}

    // بقية الدوال المطلوبة للهيكل دون مسح
    WIZ_FIX _ZN6Wizard8Security11VerifyLocalEv() {}
    WIZ_FIX _ZN6Wizard8Security13BypassLicenseEPKc(const char* key) {}
    WIZ_FIX _ZN6Wizard8Security14SetPremiumModeEb(bool enabled) {}
    WIZ_FIX _ZN6Wizard8Security15VerifySignatureEv() {}
    WIZ_FIX _ZN6Wizard8Security11ForceSignedEb(bool en) {}
    WIZ_FIX _ZN6Wizard8Security13SpoofAppStoreEv() {}
    WIZ_FIX _ZN6Wizard8Security9FakeTokenEv() {}
    WIZ_FIX _ZN6Wizard8Security15ClearDeviceIdentityEv() {}
    WIZ_FIX _ZN6Wizard4Pool15EnableGuidelineEb(bool enable) {}
    WIZ_FIX _ZN6Wizard4Pool16PredictCollisionEv() {}
    WIZ_FIX _ZN6Wizard4Pool12ForceDrawRayEv() {}
    WIZ_FIX _ZN6Wizard4Pool10SetCuePowerEf(float power) {}
    WIZ_FIX _ZN6Wizard4Pool13ShowTableGridEb(bool enable) {}
    WIZ_FIX _ZN6Wizard4Pool8AutoShotEv() {}
    WIZ_FIX _ZN6Wizard4Pool10AutoQueueEv() {}
    WIZ_FIX _ZN6Wizard8Security12EnableStealthEb(bool enabled) {}
    WIZ_FIX _ZN6Wizard8Security15SpoofDeviceGUIDEv() {}
    WIZ_FIX _ZN6Wizard6Memory11RemapRegionEPvm(void* addr, size_t size) {}
    WIZ_FIX _ZN6Wizard4Core7ShieldEv() {}
}

// --- [2] Stealth Hooks (Anti-Cheat Bypass) ---
static int (*old_stat)(const char *path, struct stat *buf);
int new_stat(const char *path, struct stat *buf) {
    if (path && (strstr(path, "MobileSubstrate") || strstr(path, "Tweak") || strstr(path, "wizard"))) {
        errno = ENOENT;
        return -1;
    }
    return old_stat(path, buf);
}

// --- [3] سيرفر المحاكاة (مطابق تماماً لبروتوكول المكتبة القديمة) ---
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
        [res setValue:@"identity" forAdditionalHeader:@"Accept-Encoding"];
        [res setValue:@"keep-alive" forAdditionalHeader:@"Connection"]; 
        
        return res;
    }];
    [_webServer startWithPort:8080 bonjourName:nil];
}

// --- [4] مُصلح الذاكرة (Memory Stabilizer) ---
void run_internal_stabilizer() {
    uintptr_t slide = _dyld_get_image_vmaddr_slide(0);
    uint32_t patch_nop = 0xD503201F; 
    unsigned long offsets[] = {0x1023A45C, 0x1023A460, 0x1023B110, 0x1055C124, 0x1044D218};
    for (int i=0; i<5; i++) {
        uintptr_t target = slide + offsets[i];
        _ZN6Wizard6Memory10WriteValueEmPvm(target, &patch_nop, 4);
    }
}

// --- [5] المحرك التشغيلي (Constructor) ---
__attribute__((constructor))
static void mirror_library_entry() {
    @autoreleasepool {
        start_mirror_auth_server();
        
        // [تعديل]: زيادة التأخير لـ 2.0 ثانية. 
        // اللعبة بتكراش لو حاولنا نعدل الذاكرة وهي لسه بتحمل الـ Frameworks الأساسية.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            MSHookFunction((void*)dlsym(RTLD_DEFAULT, "stat"), (void*)new_stat, (void**)&old_stat);
            
            // ترتيب الاستدعاءات كما في النسخة الأصلية
            _ZN6Wizard4Data15PushOffsetTableEv();
            _ZN6Wizard6Bridge18InitializeRuntimeEv();
            _ZN6Wizard8Security13BypassLicenseEPKc("WIZ-MASTER-MIRROR-2026");
            _ZN6Wizard8Security14SetPremiumModeEb(true);
            _ZN6Wizard4Pool15EnableGuidelineEb(true);
            _ZN6Wizard4Pool11LongLineModEb(true);
            _ZN6Wizard8Security18DisableIntegrityEv();
            _ZN6Wizard4Core11PatchStaticEv();
            
            run_internal_stabilizer();

            // الإشعار الذي يفتح الـ Menu
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WizardSecurityPassedNotification" object:nil];
            
            NSLog(@"[WizardNew] Stable & Active. Replaced old dylib logic.");
        });
    }
}
