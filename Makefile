# المعماريات المطلوبة
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMaster
WizardMaster_FILES = Tweak.x $(wildcard GCDWebServer/*.m)
WizardMaster_CFLAGS = -fobjc-arc -I./GCDWebServer
WizardMaster_FRAMEWORKS = UIKit Security
WizardMaster_LDFLAGS = -undefined dynamic_lookup

include $(THEOS_MAKE_PATH)/library.mk
