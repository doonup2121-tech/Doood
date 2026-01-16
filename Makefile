TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

# 1. إخبار المترجم بجمع كل ملفات الـ .m من داخل المجلد الذي ظهر في صورتك
WizardMirror_FILES = Tweak.mm $(wildcard GCDWebServer/*.m)

# 2. إخبار المترجم بالبحث عن ملفات الـ Header داخل المجلد (حل مشكلة file not found)
WizardMirror_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -IGCDWebServer

WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork
WizardMirror_LIBRARIES = substrate

include $(THEOS)/makefiles/library.mk
