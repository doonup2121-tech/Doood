# تجاهل أي أخطاء في ملف الـ control
CHECK_CONTROL_FILE = 0

ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMaster
# لو الـ GCDWebServer مش موجود لسه، شيل السطر اللي جاي ده
WizardMaster_FILES = Tweak.x $(wildcard GCDWebServer/*.m)
WizardMaster_CFLAGS = -fobjc-arc -I./GCDWebServer
WizardMaster_FRAMEWORKS = UIKit Security
WizardMaster_LDFLAGS = -undefined dynamic_lookup

include $(THEOS_MAKE_PATH)/library.mk
