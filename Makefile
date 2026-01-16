# إعدادات الهدف (كما هي)
TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

# --- [إضافة جذرية لمنع خطأ التوقيع] ---
export CODESIGN_IPA = 0
export Codesign = /usr/bin/true
export Ldid = /usr/bin/true

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

WizardMirror_FILES = Tweak.mm $(wildcard GCDWebServer/*.m)

# [تعديل 1]: إضافة علم الاستقرار والدمج الكامل (بدون تغيير القديم)
WizardMirror_LDFLAGS += -Wl,-not_for_dyld_shared_cache \
                       -Wl,-undefined,dynamic_lookup \
                       -all_load \
                       -Xlinker -unexported_symbol -Xlinker .objc_category_name_GCDWebServer*

# [تعديل 2]: إضافة الفريموركات الناقصة اللي بتسبب كراش للـ WebServer والاتصال
WizardMirror_FRAMEWORKS += UIKit Foundation Security CFNetwork MobileCoreServices SystemConfiguration

# [تعديل 3]: تحسينات السي بلس بلس لضمان مطابقة بنية المكتبة القديمة
WizardMirror_CFLAGS += -fobjc-arc \
                      -Wno-deprecated-declarations \
                      -Wno-unused-variable \
                      -Wno-unused-function \
                      -IGCDWebServer -I. \
                      -O3 \
                      -fvisibility=default

WizardMirror_LIBRARIES += substrate

include $(THEOS)/makefiles/library.mk

# إضافة لضمان عدم توقف المشروع عند التوقيع
after-package::
	@echo "Build successful, skipping signing step."
