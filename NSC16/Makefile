export TARGET = iphone:clang:16.5:14.0
export ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NSC16

NSC16_FILES = Tweak.x
NSC16_CFLAGS = -fobjc-arc

BUNDLE_LOADER_NAME = NSC16_loader
BUNDLE_NAME = NSC16Preferences

NSC16Preferences_FILES = Preferences.m
NSC16Preferences_INSTALL_PATH = /Library/PreferenceBundles
NSC16Preferences_CFLAGS = -fobjc-arc
NSC16Preferences_FRAMEWORKS = UIKit Preferences

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/bundle.mk