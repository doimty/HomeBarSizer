THEOS_PACKAGE_SCHEME ?= roothide
# 显式 SDK 16.5: "latest" 在 macOS 上会解析成 Xcode 系统 SDK, 而私有框架
# Preferences 只在 theos/sdks 的 iPhoneOS16.5.sdk 里
TARGET := iphone:clang:16.5:15.0

include $(THEOS)/makefiles/common.mk

export ARCHS = arm64e

TWEAK_NAME = HomeBarSizer
HomeBarSizer_FILES = Tweak.xm
HomeBarSizer_CFLAGS = -Wno-deprecated-declarations -fobjc-arc
HomeBarSizer_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk