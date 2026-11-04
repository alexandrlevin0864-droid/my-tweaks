export TARGET = iphone:clang:16.0:14.0
export ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NSC16

NSC16_FILES = Tweak.x
NSC16_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk