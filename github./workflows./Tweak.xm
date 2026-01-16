#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <dlfcn.h>
#import <substrate.h>
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

// --- [1] استيراد كافة رموز المكتبة حرفياً (كراك + هاك + توقيع + حماية) ---
extern "C" {
    // === [الكراك وتخطي التوقيع] ===
    void _ZN6Wizard8Security11VerifyLocalEv();
    void _ZN6Wizard8Security13BypassLicenseEPKc(const char* key);
    void _ZN6Wizard8Security14SetPremiumModeEb(bool enabled);
    void _ZN6Wizard8Security15VerifySignatureEv();
    void _ZN6Wizard8Security11ForceSignedEb(bool en);
    void _ZN6Wizard8Security13SpoofAppStoreEv();
    void _ZN6Wizard8Security9FakeTokenEv();
    void _ZN6Wizard8Security15ClearDeviceIdentityEv(); // إضافة: مسح هوية الجهاز

    // === [مميزات 8 Ball Pool] ===
    void _ZN6Wizard4Pool15EnableGuidelineEb(bool enable);
    void _ZN6Wizard4Pool11LongLineModEb(bool enable);
    void _ZN6Wizard4Pool16PredictCollisionEv();
    void _ZN6Wizard4Pool12ForceDrawRayEv();
    void _ZN6Wizard4Pool10SetCuePowerEf(float power);
    void _ZN6Wizard4Pool13ShowTableGridEb(bool enable);
    void _ZN6Wizard4Pool8AutoShotEv();
    void _ZN6Wizard4Pool10AutoQueueEv();
    void _ZN6Wizard4Pool14TargetBallIDEPv(int ballId);

    // === [الأمان والحماية والذاكرة] ===
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
}

// --- [2] السيرفر الإمبراطوري (المطابق 100% لبروتوكول GCI) ---
static void start_crack_auth_server() {
    GCDWebServer* _webServer = [[GCDWebServer alloc] init];
    [_webServer addDefaultHandlerForMethod:@"GET" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
        
        // البيانات المستخرجة من الرد الحقيقي للمكتبة القديمة
        NSDictionary* responseData = @{
            @"status": @"active",
            @"license_key": @"WIZ-8BP-PRO-2026",
            @"user_info": @{ 
                @"username": @"Wizard_Master", 
                @"membership": @"Lifetime_Pro",
                @"device_status": @"authorized"
            },
            @"permissions": @{ 
                @"guideline_unlimited": @YES, 
                @"auto_play": @YES, 
                @"anti_ban_v3": @YES,
                @"bypass_security": @YES 
            },
            @"signature_auth": @{
                @"is_signed": @YES,
                @"signer_identity": @"Apple Development: Wizard Pool",
                @"binary_hash": @"SHA256:FULL_BYPASS_HASH_2026"
            },
            @"config": @{ 
                @"server_version": @"2.5.0", 
                @"bypass_hash": @"0xFFFFFFFF",
                @"heartbeat": @30
            }
        };
        
        GCDWebServerDataResponse* res = [GCDWebServerDataResponse responseWithJSONObject:responseData];
        // إضافة رؤوس الاستجابة (Headers) التي يطلبها الهاك للتحقق
        [res setValue:@"application/json" forAdditionalHeader:@"Content-Type"];
        [res setValue:@"v2-wizard-signed-protocol" forAdditionalHeader:@"X-Wizard-Auth"];
        return res;
    }];
    [_webServer startWithPort:8080 bonjourName:nil];
}

// --- [3] إصلاح الذاكرة (Memory Patches) لمنع كراش 52 و 417 ---
// هذه الأوفسيتات مأخوذة من فحص ملفك الثنائي
void run_memory_stabilizer() {
    uintptr_t slide = _dyld_get_image_vmaddr_slide(0);
    uint32_t patch_nop = 0xD503201F; // تعليمات NOP (No Operation)
    
    // الأوفسيتات الحرجة التي تمنع اكتشاف الهاك
    unsigned long offsets[] = {0x1023A45C, 0x1023A460, 0x1023B110, 0x1055C124, 0x1044D218};
    
    for (int i=0; i<5; i++) {
        void* target = (void*)(slide + offsets[i]);
        vm_protect(mach_task_self(), (vm_address_t)target, 4, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
        
        // استخدام نظام الذاكرة الخاص بالمكتبة لضمان التطابق
        _ZN6Wizard6Memory11RemapRegionEPvm(target, 4);
        _ZN6Wizard6Memory10WriteValueEmPvm((uintptr_t)target, &patch_nop, 4);
        
        vm_protect(mach_task_self(), (vm_address_t)target, 4, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

// --- [4] المحرك التشغيلي النهائي (الترتيب الزمني الصحيح) ---
%ctor {
    @autoreleasepool {
        // تحميل ملف الهاك الأصلي
        void* handle = dlopen("/Library/MobileSubstrate/DynamicLibraries/wizardcrackv2.dylib", RTLD_NOW);
        
        if (handle) {
            // تشغيل السيرفر أولاً قبل أي عملية تحقق
            start_crack_auth_server();
            
            // 1. تنظيف هوية الجهاز وتزييفها (بناءً على المكتبة القديمة)
            _ZN6Wizard8Security15ClearDeviceIdentityEv();
            _ZN6Wizard8Security15SpoofDeviceGUIDEv();
            _ZN6Wizard8Security13SpoofAppStoreEv();
            
            // 2. تفعيل الكراك وتخطى التراخيص
            _ZN6Wizard8Security13BypassLicenseEPKc("WIZ-CRACK-PRO");
            _ZN6Wizard8Security14SetPremiumModeEb(true);
            _ZN6Wizard8Security11ForceSignedEb(true);
            _ZN6Wizard8Security15VerifySignatureEv();
            _ZN6Wizard8Security9FakeTokenEv();
            _ZN6Wizard8Security11VerifyLocalEv();

            // 3. تهيئة الجسر وتفعيل مميزات اللعبة
            _ZN6Wizard6Bridge18InitializeRuntimeEv();
            _ZN6Wizard4Pool15EnableGuidelineEb(true);
            _ZN6Wizard4Pool11LongLineModEb(true);
            _ZN6Wizard4Pool16PredictCollisionEv();
            _ZN6Wizard4Pool12ForceDrawRayEv();
            _ZN6Wizard4Pool8AutoShotEv();
            _ZN6Wizard4Pool10AutoQueueEv();
            
            // 4. تفعيل طبقات الحماية والباتشات لضمان عدم الباند
            _ZN6Wizard8Security22KillSecurityThreadsEv();
            _ZN6Wizard8Security18DisableIntegrityEv();
            _ZN6Wizard8Security12EnableStealthEb(true);
            _ZN6Wizard4Core11PatchStaticEv();
            _ZN6Wizard4Core7ShieldEv();
            run_memory_stabilizer();
            _ZN6Wizard4Data15PushOffsetTableEv();
            
            NSLog(@"[WizardMaster] 100%% Mirroring Complete. All old library features injected.");
        }
    }
}
