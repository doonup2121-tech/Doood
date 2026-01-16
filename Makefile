TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

# الحل: نجمع كل ملفات الكود (.mm و .m) في المجلد الرئيسي وفي مجلد السيرفر
WizardMirror_FILES = $(wildcard *.mm) $(wildcard *.m) $(wildcard GCDWebServer/*.m)

# إخبار المترجم بمكان ملفات الـ Header
WizardMirror_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -IGCDWebServer -I.

WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork
WizardMirror_LIBRARIES = substrate

include $(THEOS)/makefiles/library.mk
