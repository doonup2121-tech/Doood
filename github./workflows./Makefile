# [1] تعريف المعمارية والهدف
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0

# [2] تحميل إعدادات ثيوس الأساسية
include $(THEOS)/makefiles/common.mk

# [3] اسم المشروع (يجب أن يطابق ملف الـ control)
TWEAK_NAME = WizardMaster

# [4] ربط الملفات: الكود الرئيسي + جميع ملفات السيرفر الداخلي
WizardMaster_FILES = Tweak.xm $(wildcard GCDWebServer/GCDWebServer/*.m)

# [5] ربط المكتبة الجديدة (The New Library)
# ملاحظة: ضع ملف المكتبة الجديد في نفس مجلد الميك فايل وسمه 'new_library.dylib'
# أو غير الاسم أدناه لما اخترته للمكتبة الجديدة (بدون كلمة lib وبدون .dylib)
WizardMaster_LDFLAGS += -L./ -lnew_library -Wl,-undefined,dynamic_lookup

# [6] المكتبات والـ Frameworks الأساسية لنظام iOS والسيرفر
WizardMaster_FRAMEWORKS = UIKit Foundation Security CFNetwork MobileCoreServices
WizardMaster_LIBRARIES = substrate z

# [7] إعدادات المترجم ومسارات الملفات التعريفية (Headers)
WizardMaster_CFLAGS = -fobjc-arc -IGCDWebServer/GCDWebServer -I.

# [8] دمج ملف التصاريح (Entitlements) لضمان تخطي حماية النظام
WizardMaster_CODESIGN_FLAGS = -Sentitlements.plist

# [9] أمر الإنتاج النهائي
include $(THEOS_MAKE_PATH)/tweak.mk
