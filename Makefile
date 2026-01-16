TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

# التعديل هنا: بنقول للمترجم ياخد كل ملفات السيرفر معاك
WizardMirror_FILES = Tweak.mm $(wildcard GCDWebServer/*.m)
WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork
WizardMirror_LIBRARIES = substrate
# التعديل هنا: بنضيف مسار مجلد السيرفر عشان يشوف الـ .h
WizardMirror_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -IGCDWebServer

include $(THEOS)/makefiles/library.mk
