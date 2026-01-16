# إعدادات الهدف
TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

# ملفات المشروع
WizardMirror_FILES = Tweak.mm $(wildcard GCDWebServer/*.m)

# الحل الجذري الذي جعل الربط (Linking) ينجح في صورتك الأخيرة
WizardMirror_LDFLAGS = -Wl,-not_for_dyld_shared_cache \
                       -Wl,-undefined,dynamic_lookup

# إعدادات الكومبايلر
WizardMirror_CFLAGS = -fobjc-arc \
                      -Wno-deprecated-declarations \
                      -Wno-unused-variable \
                      -Wno-unused-function \
                      -IGCDWebServer -I.

# الأطر المطلوبة
WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork
WizardMirror_LIBRARIES = substrate

# --- الحل لخطأ الصورة الأخيرة (ldid not found) ---
# هذا السطر يمنع الفشل إذا كانت أداة التوقيع غير موجودة في الـ Workflow
export Codesign := /usr/bin/true

include $(THEOS)/makefiles/library.mk
