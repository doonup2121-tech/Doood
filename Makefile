# إعدادات المعمارية - arm64e ضرورية للأجهزة الحديثة
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
DEBUG = 0
FINALPACKAGE = 1

# مهم جداً للأجهزة بدون جيلبريك (وضع الجذر الحر)
THEOS_PACKAGE_SCHEME = rootless

# تجاهل فحص ملف الـ control
CHECK_CONTROL_FILE = 0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMaster

# تأكد أن ملفك في GitHub اسمه Tweak.xm
WizardMaster_FILES = Tweak.xm $(wildcard GCDWebServer/*.m)

# أعلام التجميع ودعم الـ ARC
WizardMaster_CFLAGS = -fobjc-arc -I./GCDWebServer
WizardMaster_FRAMEWORKS = UIKit Security

# --- إعدادات منع الكراش للأجهزة بدون جيلبريك ---
# 1. منع المكتبة من دخول الـ Shared Cache
# 2. تغيير مسار التثبيت ليكون بجانب ملف اللعبة (executable_path)
WizardMaster_LDFLAGS = -Xlinker -not_for_dyld_shared_cache \
                       -install_name @executable_path/WizardMaster.dylib \
                       -undefined dynamic_lookup

include $(THEOS_MAKE_PATH)/library.mk
