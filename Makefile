ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
TARGET = iphone:clang:latest:12.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DooN_Wizard
DooN_Wizard_FILES = Tweak.mm
DooN_Wizard_CFLAGS = -fobjc-arc
DooN_Wizard_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk