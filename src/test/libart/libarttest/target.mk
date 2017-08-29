TARGET = libart_test

ANDROID_PORT	 = libart
ANDROID_DIR		 = art
ANDROID_SOURCES  = test
ANDROID_BUILDFILES = build/Android.bp test/Android.bp
ANDROID_SECTIONS = /art_cc_test_library[@name=libarttest]

ANDROID_EXCLUDE_OPT += \
	-Wno-frame-larger-than=

include $(call select_from_repositories,lib/mk/libart-defaults.inc)
include $(call select_from_repositories,lib/mk/android-prg.inc)

CC_OPT += -Wno-error=unused-parameter

#
# FIXME: SUPPRESS WARNINGS! DEVELOPMENT ONLY - REMOVE FOR PRODUCTION!
$(warning SUPPRESSING WARNINGS - REMOVE FOR PRODUCTION!)
CC_OPT += -w

# For including "../../external/dlmalloc/malloc.c"
CC_OPT += -I$(call select_from_ports,dlmalloc)/dlmalloc/external/dlmalloc

SRC_CC += main.cc
LIBS   += gtest posix valgrind pthread
