ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DooN_Wizard
DooN_Wizard_FILES = Tweak.mm
DooN_Wizard_CFLAGS = -fobjc-arc
DooN_Wizard_FRAMEWORKS = UIKit Foundation

# الربط بالمكتبة القديمة بشكل صريح ومخفي في نفس الوقت
DooN_Wizard_LDFLAGS = -Wl,-reexport_library,./wizardcrackv2.dylib

include $(THEOS_MAKE_PATH)/tweak.mk