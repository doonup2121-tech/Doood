TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

# التعديل الأول: البحث عن كل ملفات الـ .m داخل المجلد الفرعي
WizardMirror_FILES = Tweak.mm $(wildcard GCDWebServer/*.m)

# التعديل الثاني: إضافة مسار المجلد للبحث عن الـ Headers
WizardMirror_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -IGCDWebServer -I.

WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork
WizardMirror_LIBRARIES = substrate

include $(THEOS)/makefiles/library.mk
