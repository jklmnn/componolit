ANDROID_PORT = core
ANDROID_DIR = system/core/libcutils
ANDROID_SECTIONS = \
	/cc_library[@name=libcutils] \
	/cc_library[@name=libcutils]/target/not_windows \
	/cc_library[@name=libcutils]/target/android_$(ANDROID_ARCH)

include $(call select_from_repositories,lib/mk/android-lib.inc)

LIBS += lwip posix libc_lwip_loopback

# For custom stdatomic.h
CC_OPT += -I$(call select_from_repositories,include/)

# O_CLOEXEC is not present in FreeBSD libc
CC_OPT_fs = -DO_CLOEXEC=0

# FIXME: We don't have mkdirat(2), pretend to be __APPLE__ to avoid using it.
CC_OPT_fs+= -D__APPLE__

# No idea where UNIT16_MAX is defined. 0xffff should be about right.
CC_OPT_fs_config = -DUINT16_MAX=0xffff

# char16_t is a C++ builtin type. Unfortunately these are .c files which we build with the C
# compiler. Probably they build it with g++ on Android. We hack around this issue here.
CC_OPT_strdup16to8 = -Dchar16_t=uint16_t
CC_OPT_strdup8to16 = -Dchar16_t=uint16_t
