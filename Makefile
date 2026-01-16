# إعدادات المعمارية والهدف
TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

# تأكد أن اسم ملف الكود في جيت هاب هو MirrorLibrary.mm
WizardMirror_FILES = MirrorLibrary.mm
WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork
WizardMirror_LIBRARIES = substrate gcdwebserver
WizardMirror_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS)/makefiles/library.mk

# هذه هي "الخانة" أو الرسالة التي ستظهر في الكونسول عند النجاح
internal-library-all::
	@echo "-----------------------------------------------"
	@echo "✅ Mirror Library Build Complete!"
	@echo "📂 Output: .theos/obj/debug/WizardMirror.dylib"
	@echo "-----------------------------------------------"
