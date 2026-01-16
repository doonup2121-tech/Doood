# إعدادات الهدف والمعمارية
TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

# جمع ملف التويك وكل ملفات المجلد الفرعي تلقائياً
WizardMirror_FILES = Tweak.mm $(wildcard GCDWebServer/*.m)
WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork
WizardMirror_LIBRARIES = substrate

# إضافة مسار المجلد للبحث عن الرموز (حل مشكلة GCDWebServer.h)
WizardMirror_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -IGCDWebServer

include $(THEOS)/makefiles/library.mk
