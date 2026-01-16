TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

# تعديل ذكي: جمع كل ملفات السيرفر من المجلد الرئيسي والفرعي
WizardMirror_FILES = Tweak.mm $(wildcard GCDWebServer/*.m) $(wildcard GCDWebServer/**/*.m)

# تعديل المسارات: إضافة كل المجلدات لمسار البحث
WizardMirror_CFLAGS = -fobjc-arc -Wno-deprecated-declarations \
                      -IGCDWebServer \
                      -I.

WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork
WizardMirror_LIBRARIES = substrate

include $(THEOS)/makefiles/library.mk
