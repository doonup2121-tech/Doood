TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = WizardMirror

# ملفات التويك + ملفات السيرفر الصح
WizardMirror_FILES = \
Tweak.mm \
$(wildcard GCDWebServer/Core/*.m) \
$(wildcard GCDWebServer/GCDWebServer/*.m)

# include paths الصح
WizardMirror_CFLAGS = \
-fobjc-arc \
-Wno-deprecated-declarations \
-IGCDWebServer/Core \
-IGCDWebServer/GCDWebServer

WizardMirror_FRAMEWORKS = UIKit Foundation Security CFNetwork
WizardMirror_LIBRARIES = substrate

include $(THEOS)/makefiles/library.mk