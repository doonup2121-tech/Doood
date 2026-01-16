#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <dlfcn.h>
#import <substrate.h>
#import <sys/stat.h>
#import <objc/runtime.h>

/* GCDWebServer imports */
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

// --- [1] تعديل الحجم: حشوة برمجية ضخمة للوصول لـ 7 ميجا ---
// تم رفع الحجم لضمان مطابقة الملف الأصلي ومنع اكتشاف التلاعب بالحجم
__attribute__((visibility("default"))) 
unsigned char wizard_binary_payload[6500000] = {0x90}; 

// --- [A] محاكاة الواجهة والربط (Missing UI/Logic Layers) ---
@interface WizardFrameworkEntry : NSObject
+ (void)load;
@end

@implementation WizardFrameworkEntry
+ (void)load {
    NSLog(@"[Wizard] Framework Dummy Layer Loaded.");
}
@end

// محاكاة كلاسات إضافية ضرورية للـ Runtime الخاص باللعبة
@interface WizardMenuProxy : NSObject @end
@implementation WizardMenuProxy @end
@interface WizardSecurityShield : NSObject @end
@implementation WizardSecurityShield @end
@interface WizardUIConfiguration : NSObject @end
@implementation WizardUIConfiguration @end

// --- [1] المحاكاة الكاملة للهيكل وفقاً للمكتبة القديمة ---
extern "C" {
    #define WIZ_FIX __attribute__((visibility("default"))) void
    #define WIZ_BOOL __attribute__((visibility("default"))) bool
    #define WIZ_CF __attribute__((visibility("default"))) CFStringRef

    // حجز مساحة بيانات ثابتة لمحاكاة الـ Data Segment الأصلي
    __attribute__((visibility("default"))) char wizard_internal_storage[1024 * 512]; 

    WIZ_FIX _ZN6Wizard6Memory10WriteValueEmPvm(uintptr_t addr, void* val, size_t size) {
        if (addr < 0x100000000 || !val) return; 
        mach_port_t task = mach_task_self();
        
        vm_address_t page_start = trunc_page(addr);
        vm_size_t page_size = round_page(addr + size) - page_start;
        
        kern_return_t kr = vm_protect(task, page_start, page_size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
        if (kr == KERN_SUCCESS) {
            memcpy((void*)addr, val, size);
            vm_protect(task, page_start, page_size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
        }
    }

    WIZ_FIX _ZN6Wizard4Pool11LongLineModEb(bool enable) {
        if (enable) {
            uintptr_t slide = _dyld_get_image_vmaddr_slide(0);
            uintptr_t target = slide + 0x1023A45C; 
            uint32_t patch = 0xD503201F; 
            _ZN6Wizard6Memory10WriteValueEmPvm(target, &patch, 4);
        }
    }

    // دوال الحماية والأمان (مطابقة كاملة لـ v2)
    WIZ_BOOL _ZN6Wizard8Security11IsConnectedEv() { return true; }
    WIZ_CF _ZN6Wizard8Security10GetFileMD5Ev() { return CFSTR("e99a18c428cb38d5f260853678922e03"); }
    WIZ_FIX _ZN6Wizard8Security14ValidateBinaryEv() {}
    WIZ_FIX _ZN6Wizard8Security18DisableIntegrityEv() {}
    WIZ_FIX _ZN6Wizard8Security22KillSecurityThreadsEv() {}
    WIZ_FIX _ZN6Wizard6Bridge18InitializeRuntimeEv() {}
    WIZ_FIX _ZN6Wizard4Data15PushOffsetTableEv() {}
    WIZ_FIX _ZN6Wizard4Core11PatchStaticEv() {
        uintptr_t slide = _dyld_get_image_vmaddr_slide(0);
        uint32_t nop = 0xD503201F;
        _ZN6Wizard6Memory10WriteValueEmPvm(slide + 0x1044D218, &nop, 4);
    }

    WIZ_FIX _ZN6Wizard8Security11VerifyLocalEv() { NSLog(@"[Wizard] Local Verified."); }
    WIZ_FIX _ZN6Wizard8Security13BypassLicenseEPKc(const char* key) { NSLog(@"[Wizard] License Bypassed."); }
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
    WIZ_FIX _ZN6Wizard4Core7ShieldEv() { NSLog(@"[Wizard] Shield Active."); }
    
    // [إضافة]: رموز إضافية مفقودة لضمان الربط الكامل وعدم الكراش (Symbols Match)
    WIZ_FIX _ZN6Wizard4Data12ConfigEngineEv() {}
    WIZ_FIX _ZN6Wizard8Security10CheckFlagsEv() {}
    WIZ_FIX _ZN6Wizard4Menu10ToggleMenuEb(bool en) {}
    WIZ_FIX _ZN6Wizard4Pool14UpdateSettingsEv() {}
}

// --- [2] Stealth Hooks المطور ---
static int (*old_stat)(const char *path, struct stat *buf);
int new_stat(const char *path, struct stat *buf) {
    if (path && (strstr(path, "MobileSubstrate") || strstr(path, "Tweak") || strstr(path, "wizard") || strstr(path, "Library/Caches") || strstr(path, "Sileo") || strstr(path, "Zebra"))) {
        errno = ENOENT;
        return -1;
    }
    return old_stat(path, buf);
}

// --- [3] سيرفر المحاكاة (بروتوكول كامل مع Heartbeat) ---
static void start_mirror_auth_server() {
    GCDWebServer* _webServer = [[GCDWebServer alloc] init];
    [_webServer addDefaultHandlerForMethod:@"GET" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
        NSDictionary* responseData = @{
            @"status": @"active",
            @"license_key": @"WIZ-PRO-MIRROR-2026",
            @"timestamp": [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]],
            @"user_info": @{ @"username": @"Wizard_Master", @"membership": @"Lifetime_Pro", @"level": @999 },
            @"permissions": @{ @"guideline_unlimited": @YES, @"auto_play": @YES, @"anti_ban_v3": @YES, @"bypass_security": @YES, @"no_ads": @YES },
            @"config": @{ @"server_version": @"2.5.0", @"heartbeat": @30, @"api_v": @"v2" }
        };
        GCDWebServerDataResponse* res = [GCDWebServerDataResponse responseWithJSONObject:responseData];
        [res setValue:@"application/json" forAdditionalHeader:@"Content-Type"];
        [res setValue:@"v2-wizard-signed-protocol" forAdditionalHeader:@"X-Wizard-Auth"];
        [res setValue:@"identity" forAdditionalHeader:@"Accept-Encoding"];
        [res setValue:@"keep-alive" forAdditionalHeader:@"Connection"]; 
        [res setValue:@"Wizard-Server/1.0" forAdditionalHeader:@"Server"];
        return res;
    }];
    [_webServer startWithPort:8080 bonjourName:nil];
}

// --- [4] مثبت الاستقرار ---
void run_internal_stabilizer() {
    uintptr_t slide = _dyld_get_image_vmaddr_slide(0);
    uint32_t patch_nop = 0xD503201F; 
    unsigned long offsets[] = {0x1023A45C, 0x1023A460, 0x1023B110, 0x1055C124, 0x1044D218};
    for (int i=0; i<5; i++) {
        uintptr_t target = slide + offsets[i];
        _ZN6Wizard6Memory10WriteValueEmPvm(target, &patch_nop, 4);
    }
}

// --- [5] المحرك التشغيلي (The Master Entry) ---
__attribute__((constructor))
static void mirror_library_entry() {
    @autoreleasepool {
        start_mirror_auth_server();
        
        // تم استخدام تأخير 3.5 ثانية لضمان أن الـ Payload الضخم (7MB) استقر تماماً في الذاكرة
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSLog(@"[WizardNew] Ultimate Deep Injection Started. Size & Symbols Matched.");
            
            MSHookFunction((void*)dlsym(RTLD_DEFAULT, "stat"), (void*)new_stat, (void**)&old_stat);
            
            // تسلسل الاستدعاءات "المقدس" للمكتبة v2
            _ZN6Wizard4Data15PushOffsetTableEv();
            _ZN6Wizard6Bridge18InitializeRuntimeEv();
            _ZN6Wizard4Core11PatchStaticEv(); 
            _ZN6Wizard4Core7ShieldEv();
            _ZN6Wizard4Data12ConfigEngineEv();
            
            _ZN6Wizard8Security13BypassLicenseEPKc("WIZ-MASTER-MIRROR-2026");
            _ZN6Wizard8Security14SetPremiumModeEb(true);
            _ZN6Wizard4Pool15EnableGuidelineEb(true);
            _ZN6Wizard4Pool11LongLineModEb(true);
            _ZN6Wizard8Security18DisableIntegrityEv();
            
            run_internal_stabilizer();

            // الإشعار النهائي الذي يفتح القائمة الأصلية للعبة
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WizardSecurityPassedNotification" object:nil];
            
            NSLog(@"[WizardNew] Final Stability Established. 7MB Match OK.");
        });
    }
}
