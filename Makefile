# المعماريات المطلوبة لأجهزة آيفون الحديثة
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
DEBUG = 0
FINALPACKAGE = 1

# مهم جداً للأجهزة بدون جيلبريك وتوافق ESign
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMaster

# تأكد أن اسم ملف الكود في ريبو جيت هاب هو Tweak.xm
WizardMaster_FILES = Tweak.xm $(wildcard GCDWebServer/*.m)

# الأطر البرمجية (Frameworks) اللازمة للواجهة والأمان
WizardMaster_FRAMEWORKS = UIKit Foundation QuartzCore Security

# إعدادات التجميع ودعم الـ ARC
WizardMaster_CFLAGS = -fobjc-arc -I./GCDWebServer

# --- إعدادات LDFLAGS المخصصة لـ ESign و Non-Jailbreak ---
# 1. جعل المسار نسبياً ليعمل داخل مجلد التطبيق (@executable_path)
# 2. السماح بالبحث عن الدوال المفقودة وقت التشغيل (dynamic_lookup)
# 3. فرض بيئة مسطحة للـ Namespaces لضمان عمل الـ Hooks
WizardMaster_LDFLAGS = -Xlinker -not_for_dyld_shared_cache \
                       -install_name @executable_path/WizardMaster.dylib \
                       -undefined dynamic_lookup \
                       -force_flat_namespace

include $(THEOS_MAKE_PATH)/library.mk
