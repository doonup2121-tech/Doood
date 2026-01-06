ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DooN_Wizard
DooN_Wizard_FILES = Tweak.x
DooN_Wizard_LIBRARIES = substrate
DooN_Wizard_CFLAGS = -fobjc-arc -Wno-error
# الربط مع المكتبة القديمة
DooN_Wizard_LDFLAGS = -L./ -Wl,-reexport_library,./wizardcrackv2.dylib

include $(THEOS_MAKE_PATH)/tweak.mk