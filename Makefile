ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DooN_Wizard
DooN_Wizard_FILES = Tweak.x
DooN_Wizard_CFLAGS = -fobjc-arc -Wno-error
# الربط السحري مع ملف الـ 7 ميجا لضمان عمل المنيو
DooN_Wizard_LDFLAGS = -L./ -Wl,-reexport_library,./wizardcrackv2.dylib -Wl,-segalign,0x4000

include $(THEOS_MAKE_PATH)/tweak.mk