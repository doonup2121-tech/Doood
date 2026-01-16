TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

# الخطوة 1: جمع ملف التويك وكل ملفات المكتبة .m من داخل المجلد
WizardMirror_FILES = Tweak.mm $(wildcard GCDWebServer/*.m)

# الخطوة 2: إضافة مسار المجلد للبحث (Include Path) عشان يشوف GCDWebServer.h
WizardMirror_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -IGCDWebServer

WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork
WizardMirror_LIBRARIES = substrate

include $(THEOS)/makefiles/library.mk
