THEOS_PACKAGE_SCHEME ?= roothide
TARGET := iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

export ARCHS = arm64e

TWEAK_NAME = HomeBarSizer
HomeBarSizer_FILES = Tweak.xm
HomeBarSizer_CFLAGS = -Wno-deprecated-declarations -fobjc-arc
HomeBarSizer_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk