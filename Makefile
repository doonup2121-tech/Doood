# إعدادات الهدف والمعمارية
TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

# [1] جمع ملف التويك وكل ملفات السيرفر التي سيتم زرعها تلقائياً
WizardMirror_FILES = Tweak.mm $(wildcard GCDWebServer/*.m)

# [2] الربط الديناميكي (أهم سطر): 
# يخبر المترجم أن الدوال المعرفة في التويك سيتم ربطها وقت التشغيل 
# وهذا يمنع ظهور خطأ "Symbol not found" في الـ Actions
WizardMirror_LDFLAGS = -Wl,-undefined,dynamic_lookup

# [3] إعدادات المترجم: دعم الـ ARC وتعريف مسارات البحث عن ملفات السيرفر
WizardMirror_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -IGCDWebServer -I.

# [4] الأطر والمكتبات المطلوبة
WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork
WizardMirror_LIBRARIES = substrate

include $(THEOS)/makefiles/library.mk
