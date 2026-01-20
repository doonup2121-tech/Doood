# المعماريات المطلوبة لضمان العمل على كافة أجهزة آيفون الحديثة
ARCHS = arm64 arm64e

# استهداف نظام iOS 14 كحد أدنى لضمان التوافق مع معظم الأجهزة
TARGET = iphone:clang:latest:14.0

# إيقاف وضع التصحيح وتفعيل التحسين النهائي لتقليل حجم المكتبة ومنع الكراش
DEBUG = 0
FINALPACKAGE = 1

# ضبط بيئة العمل للعمل بدون جيلبريك (Rootless)
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

# اسم المكتبة الناتجة التي ستقوم برفعها في ESign
LIBRARY_NAME = WizardMaster

# الملفات المصدرية (تأكد أن ملف الكود في GitHub بنفس هذا الاسم)
WizardMaster_FILES = Tweak.xm

# الأطر البرمجية اللازمة للواجهة الرسومية ونظام التشغيل
WizardMaster_FRAMEWORKS = UIKit Foundation QuartzCore Security

# --- إعدادات المعالج (حل مشكلة الصورة) ---
# 1. تفعيل ARC لإدارة الذاكرة تلقائياً
# 2. تجاهل تحذيرات الأكواد الملغية لمنع توقف البناء (حل مشكلة keyWindow)
WizardMaster_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

# --- إعدادات الربط (التقنية البديلة للرابط الخارجي) ---
# 1. تحديد مسار التثبيت ليكون داخل مجلد اللعبة (@executable_path)
# 2. السماح بالبحث عن الدوال وقت التشغيل (Dynamic Lookup) لعدم الاعتماد على ملفات خارجية
# 3. فرض بيئة مسطحة للـ Namespaces لضمان عمل الـ Hooks في بيئة الـ Sandbox
WizardMaster_LDFLAGS = -install_name @executable_path/WizardMaster.dylib \
                       -undefined dynamic_lookup \
                       -force_flat_namespace

include $(THEOS_MAKE_PATH)/library.mk
