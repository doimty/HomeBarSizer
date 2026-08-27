include $(THEOS)/makefiles/common.mk

TARGET := iphone:clang:latest:15.0

export ARCHS = arm64e

BUNDLE_NAME = HomeBarSizer
HomeBarSizer_FILES = HBRootListController.m
HomeBarSizer_INSTALL_PATH = /Library/PreferenceBundles
HomeBarSizer_FRAMEWORKS = UIKit
HomeBarSizer_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/HomeBarSizer.plist$(ECHO_END)