TARGET = libart_test

ANDROID_PORT	 = libart
ANDROID_DIR		 = art
ANDROID_BUILDFILES = build/Android.bp test/Android.bp
ANDROID_SECTIONS = /art_cc_test_library[@name=libarttest]


ANDROID_EXCLUDE_OPT += \
	-Wno-frame-larger-than=

include $(call select_from_repositories,lib/mk/libart-defaults.inc)
include $(call select_from_repositories,lib/mk/android-prg.inc)

CC_OPT += -Wno-error=unused-parameter

# FIXME: Move to lib/mk/libart.inc
# Use compiler's definition of UINT64_C/INT64_C as a fallback
CC_OPT += -DUINT64_C=__UINT64_C
CC_OPT += -DINT64_C=__INT64_C

#
# FIXME: SUPPRESS WARNINGS! DEVELOPMENT ONLY - REMOVE FOR PRODUCTION!
$(warning SUPPRESSING WARNINGS - REMOVE FOR PRODUCTION!)
CC_OPT += -w

SRC_CC += main.cc
LIBS   += gtest posix
