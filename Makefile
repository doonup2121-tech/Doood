TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

WizardMirror_FILES = Tweak.mm $(wildcard GCDWebServer/*.m)

# --- الحل الجذري هنا ---
# السطر الأول: يمنع المكتبة من الـ Shared Cache كما طلب الخطأ في الصورة
# السطر الثاني: يحل مشكلة البحث عن الرموز المفقودة
WizardMirror_LDFLAGS = -Wl,-not_for_dyld_shared_cache \
                       -Wl,-undefined,dynamic_lookup

WizardMirror_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -IGCDWebServer -I.
WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork
WizardMirror_LIBRARIES = substrate

include $(THEOS)/makefiles/library.mk
