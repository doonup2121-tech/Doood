# تحديد المعماريات لضمان العمل على كافة أجهزة الآيفون الحديثة
ARCHS = arm64 arm64e

# استهداف إصدار iOS 14 كحد أدنى لضمان الاستقرار والتوافق
TARGET = iphone:clang:latest:14.0

# إعدادات الحزمة النهائية لتقليل الحجم ومنع الكراش (تعطيل وضع المطور)
DEBUG = 0
FINALPACKAGE = 1

# ضبط بيئة العمل للحقن بدون جيلبريك (Rootless)
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

# اسم المكتبة (يجب أن يكون نفس الاسم المستخدم في إعدادات ESign)
LIBRARY_NAME = WizardMaster

# ملفات الكود المصدرية
WizardMaster_FILES = Tweak.xm

# الأطر البرمجية اللازمة للعمليات والحماية والواجهة
WizardMaster_FRAMEWORKS = UIKit Foundation QuartzCore Security

# --- إعدادات المعالج (حل مشكلة الصورة الأولى) ---
# تفعيل ARC وإضافة أمر تجاهل التحذيرات المسببة لفشل الـ Build (Deprecated declarations)
WizardMaster_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

# --- إعدادات الربط (حل مشكلة الصورة الثانية) ---
# 1. إزالة -force_flat_namespace لأنها تتعارض مع المكتبات الديناميكية وتسبب Error 1
# 2. تعريف install_name ليكون مسار الحقن داخل مجلد اللعبة
# 3. السماح بالبحث عن الدوال وقت التشغيل (undefined dynamic_lookup) للاستغناء عن Substrate
WizardMaster_LDFLAGS = -install_name @executable_path/WizardMaster.dylib \
                       -undefined dynamic_lookup

include $(THEOS_MAKE_PATH)/library.mk
