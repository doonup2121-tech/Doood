# إعدادات المعمارية
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
DEBUG = 0
FINALPACKAGE = 1
CHECK_CONTROL_FILE = 0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMaster

# تأكد أن اسم الملف Tweak.xm
WizardMaster_FILES = Tweak.xm $(wildcard GCDWebServer/*.m)
WizardMaster_CFLAGS = -fobjc-arc -I./GCDWebServer
WizardMaster_FRAMEWORKS = UIKit Security

# --- الحل السحري لخطأ الصورة الثالثة ---
# نمنع المكتبة من دخول الـ Shared Cache لنتخطى رفض الـ Linker
WizardMaster_LDFLAGS = -Xlinker -not_for_dyld_shared_cache

include $(THEOS_MAKE_PATH)/library.mk
