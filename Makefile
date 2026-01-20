# إعدادات المعمارية - تدعم الأجهزة الحديثة (A12+)
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
DEBUG = 0
FINALPACKAGE = 1

# تجاهل فحص ملف الـ control لتجنب أخطاء التجميع في GitHub
CHECK_CONTROL_FILE = 0

include $(THEOS)/makefiles/common.mk

# اسم المكتبة الناتجة سيكون WizardMaster.dylib
LIBRARY_NAME = WizardMaster

# الملفات المصدرية - الآن نستخدم التمديد .xm لتمكين الـ Hooks
WizardMaster_FILES = Tweak.xm $(wildcard GCDWebServer/*.m)

# أعلام التجميع لدعم الـ ARC والمسارات (لا تزال CFLAGS تعمل مع .xm)
WizardMaster_CFLAGS = -fobjc-arc -I./GCDWebServer
# ربط المكتبات الأساسية للنظام
WizardMaster_FRAMEWORKS = UIKit Security
# السماح بالربط الديناميكي لمنع خطأ الـ Symbols المفقودة
WizardMaster_LDFLAGS = -undefined dynamic_lookup

include $(THEOS_MAKE_PATH)/library.mk
