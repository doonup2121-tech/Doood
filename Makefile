TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

export CODESIGN_IPA = 0
export Codesign = /usr/bin/true
export Ldid = /usr/bin/true

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

WizardMirror_FILES = Tweak.mm $(wildcard GCDWebServer/*.m)

# [التعديل الجوهري]: إضافة force_load و all_load لدمج كل الرموز
# تم إضافة -lc++ لضمان عمل رموز C++ المضافة لمنع كراش "لمس الأيقونة"
WizardMirror_LDFLAGS = -Wl,-not_for_dyld_shared_cache \
                       -Wl,-undefined,dynamic_lookup \
                       -all_load \
                       -fobjc-link-runtime \
                       -lc++ \
                       -lz

# تم إضافة تحسينات لضمان عدم حذف الرموز غير المستخدمة ظاهرياً (Dead Code Stripping)
WizardMirror_CFLAGS = -fobjc-arc \
                      -Wno-deprecated-declarations \
                      -Wno-unused-variable \
                      -Wno-unused-function \
                      -IGCDWebServer -I. \
                      -O3 \
                      -fvisibility=default

# [إضافة فريموركات]: دي الفريموركات اللي بتخلي الملف حجمه يكبر ويبقى مستقر
WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork MobileCoreServices SystemConfiguration QuartzCore CoreGraphics CoreTelephony CoreText

WizardMirror_LIBRARIES = substrate c++

include $(THEOS)/makefiles/library.mk

after-package::
	@echo "Build successful. Check the file size now."
