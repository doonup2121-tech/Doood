TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

# [1] دمج ملف التوقيع الخاص بك تلقائياً
export Entitlements = Entitlements.plist

export CODESIGN_IPA = 0
export Codesign = /usr/bin/true
export Ldid = /usr/bin/true

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

WizardMirror_FILES = Tweak.mm $(wildcard GCDWebServer/*.m)

# [2] الحفاظ على LDFLAGS مع ضمان مسار التحميل التلقائي
WizardMirror_LDFLAGS = -Wl,-not_for_dyld_shared_cache \
                       -Wl,-undefined,dynamic_lookup \
                       -all_load \
                       -fobjc-link-runtime \
                       -lc++ \
                       -lz \
                       -Wl,-dead_strip_dylibs \
                       -Wl,-no_compact_unwind \
                       -Wl,-install_name,@loader_path/WizardMirror.dylib

WizardMirror_CFLAGS = -fobjc-arc \
                      -Wno-deprecated-declarations \
                      -Wno-unused-variable \
                      -Wno-unused-function \
                      -IGCDWebServer -I. \
                      -O3 \
                      -fvisibility=default \
                      -rdynamic

WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork MobileCoreServices SystemConfiguration QuartzCore CoreGraphics CoreTelephony CoreText AdSupport AppSupport JavaScriptCore

WizardMirror_LIBRARIES = substrate c++ sqlite3 z

include $(THEOS)/makefiles/library.mk

# [3] تعديل أمر after-package لدمج الـ Entitlements برمجياً في ملف الـ dylib
after-package::
	@echo "Signing library with Entitlements.plist..."
	@ldid -SEntitlements.plist $(THEOS_OBJ_DIR)/WizardMirror.dylib
	@echo "Build successful. Fixed Loader Path and Entitlements for direct signing."
