PACKAGE_VERSION = 1.0.4
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:11.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Silactions
Silactions_FILES = Tweak.xm
Silactions_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
