# إعدادات الهدف والمعمارية
TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

# [1] جمع ملف التويك وملفات السيرفر التي سيتم زرعها بواسطة الورك فلو
WizardMirror_FILES = Tweak.mm $(wildcard GCDWebServer/*.m)

# [2] سطر الحل النهائي للأخطاء: يسمح بالبحث عن الدوال وقت التشغيل
WizardMirror_LDFLAGS = -Wl,-undefined,dynamic_lookup

# [3] إعدادات المترجم ودعم الـ ARC ومسارات السيرفر
WizardMirror_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -IGCDWebServer -I.

# [4] الأطر والمكتبات المطلوبة
WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork
WizardMirror_LIBRARIES = substrate

include $(THEOS)/makefiles/library.mk
