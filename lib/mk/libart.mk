ANDROID_PORT = libart
ANDROID_DIR = art
ANDROID_INCLUDES = runtime runtime/arch
ANDROID_SOURCES = runtime
ANDROID_BUILDFILES = test/Android.bp build/Android.bp runtime/Android.bp
ANDROID_SECTIONS = \
	/art_cc_library[@name=libart] \
	/art_cc_library[@name=libart]/arch/$(ANDROID_ARCH)

include $(call select_from_repositories,lib/mk/libart-defaults.inc)
include $(call select_from_repositories,lib/mk/android-lib.inc)




# Position independent library
CC_OPT += -fPIC

#
# FIXME: SUPPRESS WARNINGS! DEVELOPMENT ONLY - REMOVE FOR PRODUCTION!
$(warning SUPPRESSING WARNINGS - REMOVE FOR PRODUCTION!)
CC_OPT += -w

LIBS += valgrind dlmalloc zlib icu
