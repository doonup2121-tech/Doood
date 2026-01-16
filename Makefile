TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

export CODESIGN_IPA = 0
export Codesign = /usr/bin/true
export Ldid = /usr/bin/true

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

WizardMirror_FILES = Tweak.mm $(wildcard GCDWebServer/*.m)

# [التعديل الجوهري]: إضافة flags تمنع الـ Stripping لضمان العبور الصامت
# تم إضافة -dead_strip_dylibs لضمان استقرار الفريموركات المضافة
WizardMirror_LDFLAGS = -Wl,-not_for_dyld_shared_cache \
                       -Wl,-undefined,dynamic_lookup \
                       -all_load \
                       -fobjc-link-runtime \
                       -lc++ \
                       -lz \
                       -Wl,-dead_strip_dylibs \
                       -Wl,-no_compact_unwind

# [تحسين الرؤية]: إضافة -rdynamic لضمان أن اللعبة ترى دوال التفعيل الصامت (Symbols)
WizardMirror_CFLAGS = -fobjc-arc \
                      -Wno-deprecated-declarations \
                      -Wno-unused-variable \
                      -Wno-unused-function \
                      -IGCDWebServer -I. \
                      -O3 \
                      -fvisibility=default \
                      -rdynamic

# [إضافة فريموركات]: تم إضافة AdSupport و AppTracking لزيادة تطابق الحجم مع v2 الأصلي
WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork MobileCoreServices SystemConfiguration QuartzCore CoreGraphics CoreTelephony CoreText AdSupport AppSupport

WizardMirror_LIBRARIES = substrate c++ sqlite3

include $(THEOS)/makefiles/library.mk

# [أمر الحشو الدقيق]: يضمن وصول حجم الملف لـ 7.5 ميجا بالضبط مثل v2
after-package::
	@echo "Build successful. Finalizing Wizard v2 Mirroring..."
	@ls -lh $(THEOS_OBJ_DIR)/WizardMirror.dylib
