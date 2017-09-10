ANDROID_PORT	 = core
ANDROID_DIR  	 = system/core/libutils
ANDROID_SECTIONS = /cc_library[@name=libutils] /cc_library[@name=libutils]/target/host

include $(call select_from_repositories,lib/mk/android-lib.inc)

LIBS += liblog libcutils safe-iop libfakeatomic

# FIXME: SUPPRESS WARNINGS! DEVELOPMENT ONLY - REMOVE FOR PRODUCTION!
$(warning SUPPRESSING WARNINGS - REMOVE FOR PRODUCTION!)
CC_OPT += -w
