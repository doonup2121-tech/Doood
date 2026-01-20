# المعماريات المستهدفة
ARCHS = arm64 arm64e

# إصدار النظام المستهدف
TARGET = iphone:clang:latest:14.0

# إعدادات الحزمة النهائية لتقليل الحجم ومنع الكراش
DEBUG = 0
FINALPACKAGE = 1
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMaster

# ملفات الكود (تأكد من مطابقة الاسم في ريبو جيت هاب)
WizardMaster_FILES = Tweak.xm

# الأطر البرمجية اللازمة
WizardMaster_FRAMEWORKS = UIKit Foundation QuartzCore Security

# حل مشكلة الصورة الأولى (تجاهل تحذيرات الأكواد القديمة لمنع توقف الـ Build)
WizardMaster_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

# حل مشكلة الصورة الثانية (حذف force_flat_namespace المسببة للتعارض)
# واستخدام install_name لتعريف المسار داخل التطبيق في ESign
WizardMaster_LDFLAGS = -install_name @executable_path/WizardMaster.dylib \
                       -undefined dynamic_lookup

include $(THEOS_MAKE_PATH)/library.mk
