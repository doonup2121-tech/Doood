# إعدادات الهدف والمعمارية
TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

# اسم المكتبة (يجب أن يطابق المستخدم في ملف plist)
LIBRARY_NAME = WizardMirror

# ملفات المشروع (تأكد من وجود مجلد GCDWebServer بجانب Tweak.mm)
WizardMirror_FILES = Tweak.mm $(wildcard GCDWebServer/*.m)

# --- الحل الجذري للأخطاء التي ظهرت في الصور ---

# 1. حل مشكلة السطر 28 (Shared Cache Eligible) و (Dynamic Lookup)
# -not_for_dyld_shared_cache: يخبر النظام أن هذه المكتبة للحقن وليست للنظام الأساسي
# -undefined dynamic_lookup: يسمح بالبحث عن الدوال المفقودة وقت التشغيل (داخل اللعبة)
WizardMirror_LDFLAGS = -Wl,-not_for_dyld_shared_cache \
                       -Wl,-undefined,dynamic_lookup

# 2. إعدادات الكومبايلر وإدراج المسارات
# -fobjc-arc: لتفعيل إدارة الذاكرة التلقائية لـ GCDWebServer
# -I.: للبحث عن الهيدرز في المجلد الحالي
WizardMirror_CFLAGS = -fobjc-arc \
                      -Wno-deprecated-declarations \
                      -Wno-unused-variable \
                      -Wno-unused-function \
                      -IGCDWebServer -I.

# 3. الأطر والمكتبات المطلوبة
WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork
WizardMirror_LIBRARIES = substrate

include $(THEOS)/makefiles/library.mk

# أمر ينفذ بعد التنظيف (اختياري)
after-clean::
	rm -rf ./packages/*
