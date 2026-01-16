#import <Foundation/Foundation.h>

namespace Wizard {
    namespace Security {
        void VerifyLocalEv();
        void BypassLicenseEPKc(const char* key);
        void SetPremiumModeEb(bool enabled);
        void VerifySignatureEv();
        void ForceSignedEb(bool en);
        void SpoofAppStoreEv();
        void FakeTokenEv();
        void ClearDeviceIdentityEv();
        void KillSecurityThreadsEv();
        void EnableStealthEb(bool enabled);
        void DisableIntegrityEv();
        void SpoofDeviceGUIDEv();
        void ValidateBinaryEv();
        CFStringRef GetFileMD5Ev();
        bool IsConnectedEv();
    }
    namespace Pool {
        void EnableGuidelineEb(bool enable);
        void LongLineModEb(bool enable);
        void PredictCollisionEv();
        void ForceDrawRayEv();
        void SetCuePowerEf(float power);
        void ShowTableGridEb(bool enable);
        void AutoShotEv();
        void AutoQueueEv();
    }
    namespace Memory {
        void RemapRegionEPvm(void* addr, size_t size);
        void WriteValueEmPvm(uintptr_t addr, void* val, size_t size);
    }
    namespace Core {
        void PatchStaticEv();
        void ShieldEv();
    }
    namespace Bridge {
        void InitializeRuntimeEv();
    }
    namespace Data {
        void PushOffsetTableEv();
    }
}
