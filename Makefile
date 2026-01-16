TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

# تأكد أن اسم ملف الكود عندك هو Tweak.mm كما في الصورة
WizardMirror_FILES = Tweak.mm
WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork
WizardMirror_LIBRARIES = substrate gcdwebserver
WizardMirror_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS)/makefiles/library.mk
