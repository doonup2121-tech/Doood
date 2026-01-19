# المعماريات المدعومة للأجهزة الحديثة
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

# اسم المكتبة الناتجة سيكون WizardMaster.dylib
LIBRARY_NAME = WizardMaster

# الملف المصدر (تأكد أن اسم الملف عندك Tweak.x أو قم بتغييره هنا)
WizardMaster_FILES = Tweak.x
WizardMaster_CFLAGS = -fobjc-arc
WizardMaster_FRAMEWORKS = UIKit Security
WizardMaster_LDFLAGS = -undefined dynamic_lookup

include $(THEOS_MAKE_PATH)/library.mk
