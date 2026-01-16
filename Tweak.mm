#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <dlfcn.h>
#import <substrate.h>
#import <sys/stat.h>
#import <objc/runtime.h>
#import <sys/sysctl.h> 
#import <sys/time.h>   

/* GCDWebServer imports */
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

// --- [1] محاكاة هيكل الذاكرة والأقسام الأمنية (Critical for No-Crash on Launch) ---
__attribute__((section("__TEXT,__restrict"))) static const char wizard_restrict[] = "RESTRICT";
__attribute__((section("__TEXT,__wizard_txt"))) static const char wizard_magic[] = "WIZARD_v2_PROTECTED";
__attribute__((section("__DATA,__interpose"))) static const void* wizard_interpose_data[2] = {0};
__attribute__((section("__DATA,__wizard_off"))) static uintptr_t wizard_offsets_table[1000] = {0x1023A45C, 0x1044D218};

__attribute__((visibility("default"))) 
unsigned char wizard_binary_payload[7500000] = {0x90}; 

// --- [A] محاكاة الواجهة والربط المتقدم ---
@interface WizardFrameworkEntry : NSObject + (void)load; @end
@implementation WizardFrameworkEntry + (void)load { NSLog(@"[Wizard] Core Entry Loaded."); } @end
@interface WizardMenuProxy : NSObject @end @implementation WizardMenuProxy @end
@interface WizardSecurityShield : NSObject @end @implementation WizardSecurityShield @end
@interface WizardUIConfiguration : NSObject @end @implementation WizardUIConfiguration @end
@interface WizLocalStorage : NSObject @end @implementation WizLocalStorage @end
@interface WizardCloudSync : NSObject @end @implementation WizardCloudSync @end
@interface WizardAnalytics : NSObject @end @implementation WizardAnalytics @end

// --- [1] المحاكاة الكاملة للهيكل (C++, Physics, and VTables) ---
extern "C" {
    #define WIZ_FIX __attribute__((visibility("default"))) void
    #define WIZ_BOOL __attribute__((visibility("default"))) bool
    #define WIZ_CF __attribute__((visibility("default"))) CFStringRef

    WIZ_BOOL _ZN6Wizard8Security10NeedsVerifyEv() { return false; }
    WIZ_BOOL _ZN6Wizard8Security15IsLicenseActiveEv() { return true; }
    WIZ_BOOL _ZN6Wizard8Security11IsBypassedEv() { return true; }

    WIZ_FIX _ZTI6Wizard4PoolE() {} 
    WIZ_FIX _ZTI6Wizard8SecurityE() {}
    WIZ_FIX _ZTI6Wizard4MathE() {}
    WIZ_FIX _ZTS6Wizard4PoolE() {}
    #define completionHandler_t void (^)(NSData *data, NSURLResponse *response, NSError *error)
    WIZ_FIX _ZTS6Wizard8SecurityE() {}
    WIZ_FIX _ZTS6Wizard4MathE() {}

    WIZ_FIX _ZNKSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE4sizeEv() {}
    WIZ_FIX _ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEC1ERKS5_() {}
    WIZ_FIX _ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEED1Ev() {}
    WIZ_FIX _ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEaSERKS5_() {} 
    WIZ_FIX _ZNSt3__112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEEC1EPKc() {}

    WIZ_FIX _ZN6Wizard4Core4InitEv() {}
    WIZ_FIX _ZN6Wizard8Security7PrepareEv() {}
    WIZ_FIX _ZN6Wizard4PoolC1Ev() {} 
    WIZ_FIX _ZN6Wizard4PoolD1Ev() {}
    WIZ_FIX _ZN6Wizard12VisualEngine11InitializeEv() {}

    WIZ_FIX cs_open() {} 
    WIZ_FIX cs_disasm() {}
    WIZ_FIX SHA256_Init() {}
    WIZ_FIX AES_set_encrypt_key() {}
    
    WIZ_FIX _ZTVN6Wizard10CoreObjectE() {}
    WIZ_FIX _ZTVN6Wizard4MathE() {}
    WIZ_FIX _ZTVN6Wizard4PoolE() {} 
    WIZ_FIX _ZTVN6Wizard8SecurityE() {}
    WIZ_FIX _ZTVN6Wizard4CoreE() {}
    WIZ_FIX _ZTVN6Wizard12VisualEngineE() {}

    WIZ_FIX _ZN6Wizard4Math10CalculatorEv() {}
    WIZ_FIX _ZN6Wizard12VisualEngine7DrawRayEv() {}
    WIZ_FIX _ZN6Wizard12VisualEngine11ClearCanvasEv() {}
    
    __attribute__((visibility("default"))) 
    double _ZN6Wizard6Config10GlobalVarsE[100] = {1.0, 0.5, 2.0}; 

    WIZ_FIX _ZN6Wizard6Memory10WriteValueEmPvm(uintptr_t addr, void* val, size_t size) {
        if (addr < 0x100000000 || !val) return; 
        mach_port_t task = mach_task_self();
        vm_address_t page_start = trunc_page(addr);
        vm_size_t page_size = round_page(addr + size) - page_start;
        if (vm_protect(task, page_start, page_size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY) == KERN_SUCCESS) {
            memcpy((void*)addr, val, size);
            vm_protect(task, page_start, page_size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
        }
    }

    WIZ_FIX _ZN6Wizard4Pool11LongLineModEb(bool enable) {
        if (enable) {
            uintptr_t slide = _dyld_get_image_vmaddr_slide(0);
            uint32_t patch = 0xD503201F; 
            _ZN6Wizard6Memory10WriteValueEmPvm(slide + 0x1023A45C, &patch, 4);
        }
    }

    WIZ_BOOL _ZN6Wizard8Security11IsConnectedEv() { return true; }
    WIZ_CF _ZN6Wizard8Security10GetFileMD5Ev() { return CFSTR("e99a18c428cb38d5f260853678922e03"); }
    WIZ_FIX _ZN6Wizard8Security14ValidateBinaryEv() {}
    WIZ_FIX _ZN6Wizard8Security18DisableIntegrityEv() {}
    WIZ_FIX _ZN6Wizard6Bridge18InitializeRuntimeEv() {}
    WIZ_FIX _ZN6Wizard4Data15PushOffsetTableEv() {}
    WIZ_FIX _ZN6Wizard4Core11PatchStaticEv() {}
    WIZ_FIX _ZN6Wizard4Core7ShieldEv() { NSLog(@"[Wizard] Shield Active."); }
    WIZ_FIX _ZN6Wizard8Security13BypassLicenseEPKc(const char* key) {}
    WIZ_FIX _ZN6Wizard8Security15RegisterLicenseEv() {}
    WIZ_FIX _ZN6Wizard8Security11AntiDebugMeEv() {} 
}

// --- [2] Stealth Hooks & Crash Prevention ---
static void* (*old_dlsym)(void* handle, const char* symbol);
void* new_dlsym(void* handle, const char* symbol) {
    if (symbol && strstr(symbol, "Wizard")) return dlsym(RTLD_DEFAULT, symbol);
    return old_dlsym(handle, symbol);
}

static id (*old_auth_init)(id self, SEL _cmd);
id new_auth_init(id self, SEL _cmd) { return nil; }

static int (*old_stat)(const char *path, struct stat *buf);
int new_stat(const char *path, struct stat *buf) {
    if (path && (strstr(path, "Tweak") || strstr(path, "Wizard") || strstr(path, ".dylib"))) {
        errno = ENOENT; return -1;
    }
    return old_stat(path, buf);
}

static FILE* (*old_fopen)(const char *path, const char *mode);
FILE* new_fopen(const char *path, const char *mode) {
    if (path && strstr(path, "wizard")) return NULL;
    return old_fopen(path, mode);
}

int (*old_sysctl)(int *name, u_int namelen, void *info, size_t *infosize, void *newp, size_t newlen);
int new_sysctl(int *name, u_int namelen, void *info, size_t *infosize, void *newp, size_t newlen) {
    int ret = old_sysctl(name, namelen, info, infosize, newp, newlen);
    if (namelen == 4 && name[0] == CTL_KERN && name[1] == KERN_PROC && name[2] == KERN_PROC_PID && info) {
        ((struct kinfo_proc *)info)->kp_proc.p_flag &= ~P_TRACED; 
    }
    return ret;
}

// --- [3] السلاح السري: اعتراض الطلبات وتزوير الرد ( NSURLSession Hook ) ---
static id (*old_dataTaskWithRequest)(NSURLSession* self, SEL _cmd, NSURLRequest* request, completionHandler_t completionHandler);
id new_dataTaskWithRequest(NSURLSession* self, SEL _cmd, NSURLRequest* request, completionHandler_t completionHandler) {
    NSString *url = request.URL.absoluteString;
    if ([url containsString:@"revenuecat"] || [url containsString:@"verify"] || [url containsString:@"wizard-auth"]) {
        NSDictionary* responseDict = @{
            @"request_date": @"2026-01-16T12:00:00Z",
            @"subscriber": @{
                @"entitlements": @{
                    @"premium_access": @{@"expires_date": @"2099-12-31T23:59:59Z", @"product_identifier": @"com.wizard.full_access.yearly"},
                    @"all_features": @{@"expires_date": @"2099-12-31T23:59:59Z", @"product_identifier": @"com.wizard.unlock_all"}
                },
                @"original_app_user_id": @"wizard_user_stable",
                @"subscriptions": @{@"com.wizard.full_access.yearly": @{@"expires_date": @"2099-12-31T23:59:59Z", @"store": @"app_store", @"purchase_date": @"2024-01-01T00:00:00Z"}}
            }
        };
        NSData *data = [NSJSONSerialization dataWithJSONObject:responseDict options:0 error:nil];
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{@"Content-Type": @"application/json"}];
        if (completionHandler) completionHandler(data, response, nil);
        return nil; 
    }
    return old_dataTaskWithRequest(self, _cmd, request, completionHandler);
}

static NSURL* (*old_URLWithString)(id self, SEL _cmd, NSString* URLString);
NSURL* new_URLWithString(id self, SEL _cmd, NSString* URLString) {
    if ([URLString containsString:@"revenuecat"] || [URLString containsString:@"verify"]) {
        return old_URLWithString(self, _cmd, @"http://127.0.0.1:8080/v1/subscribers/wizard_user_stable");
    }
    return old_URLWithString(self, _cmd, URLString);
}

// --- [4] سيرفر المحاكاة المحسن ---
static void start_mirror_auth_server() {
    GCDWebServer* _webServer = [[GCDWebServer alloc] init];
    [_webServer addDefaultHandlerForMethod:@"GET" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
        return [GCDWebServerDataResponse responseWithJSONObject:@{@"status": @"success", @"code": @200}];
    }];
    [_webServer startWithPort:8080 bonjourName:nil];
}

void run_internal_stabilizer() {
    uintptr_t slide = _dyld_get_image_vmaddr_slide(0);
    uint32_t nop = 0xD503201F; 
    unsigned long offsets[] = {0x1023A45C, 0x1023A460, 0x1023B110, 0x1055C124, 0x1044D218};
    for (int i=0; i<5; i++) _ZN6Wizard6Memory10WriteValueEmPvm(slide + offsets[i], &nop, 4);
}

// --- [5] المحرك التشغيلي (Constructor 0) ---
__attribute__((constructor(0)))
static void mirror_library_entry() {
    @autoreleasepool {
        start_mirror_auth_server();

        MSHookFunction((void*)dlsym, (void*)new_dlsym, (void**)&old_dlsym);
        MSHookFunction((void*)sysctl, (void*)new_sysctl, (void**)&old_sysctl);
        MSHookFunction((void*)dlsym(RTLD_DEFAULT, "stat"), (void*)new_stat, (void**)&old_stat);
        
        MSHookMessageEx([NSURLSession class], @selector(dataTaskWithRequest:completionHandler:), (IMP)new_dataTaskWithRequest, (IMP*)&old_dataTaskWithRequest);
        MSHookMessageEx(objc_getMetaClass("NSURL"), @selector(URLWithString:), (IMP)new_URLWithString, (IMP*)&old_URLWithString);

        Class authClass = NSClassFromString(@"WizardAuthViewController");
        if (authClass) {
            MSHookMessageEx(authClass, @selector(init), (IMP)new_auth_init, (IMP*)&old_auth_init);
            MSHookMessageEx(authClass, @selector(viewDidLoad), (IMP)new_auth_init, (IMP*)NULL);
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _ZN6Wizard4Core4InitEv();
            _ZN6Wizard8Security7PrepareEv();
            _ZN6Wizard12VisualEngine11InitializeEv();
            _ZN6Wizard4Data15PushOffsetTableEv();
            _ZN6Wizard6Bridge18InitializeRuntimeEv();
            _ZN6Wizard4Core7ShieldEv();
            _ZN6Wizard8Security13BypassLicenseEPKc("WIZ-MASTER-2026");
            _ZN6Wizard4Pool11LongLineModEb(true);
            _ZN6Wizard8Security15RegisterLicenseEv();
            run_internal_stabilizer();
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.wizard.v2.auth.success" object:nil];
        });
    }
}
