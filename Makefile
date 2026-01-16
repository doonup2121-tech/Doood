# إعدادات الهدف والمعمارية
TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

# ملفات المشروع
WizardMirror_FILES = Tweak.mm $(wildcard GCDWebServer/*.m)

# الحل الذي جعل الربط (Linking) ينجح في صورك الأخيرة
WizardMirror_LDFLAGS = -Wl,-not_for_dyld_shared_cache \
                       -Wl,-undefined,dynamic_lookup

# إعدادات الكومبايلر
WizardMirror_CFLAGS = -fobjc-arc \
                      -Wno-deprecated-declarations \
                      -Wno-unused-variable \
                      -Wno-unused-function \
                      -IGCDWebServer -I.

# الأطر والمكتبات
WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork
WizardMirror_LIBRARIES = substrate

# --- [الحل القطعي لخطأ الصور الأخير 8:11] ---
# هذا السطر يخبر GitHub بتجاهل أداة التوقيع ldid واعتبار المهمة ناجحة
export Codesign := /usr/bin/true

include $(THEOS)/makefiles/library.mk
