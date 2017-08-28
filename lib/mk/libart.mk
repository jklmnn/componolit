ANDROID_PORT = libart
ANDROID_DIR = art
ANDROID_INCLUDES = runtime runtime/arch
ANDROID_SOURCES = runtime
ANDROID_BUILDFILES = test/Android.bp build/Android.bp runtime/Android.bp
ANDROID_SECTIONS = \
	/art_cc_library[@name=libart] \
	/art_cc_library[@name=libart]/arch/$(ANDROID_ARCH)

ANDROID_EXCLUDE_OPT = \
	-Wimplicit-fallthrough \
	-Wint-to-void-pointer-cast \
	-Wthread-safety \
	-Wthread-safety-negative \
	-Wunreachable-code-break \
	-Wunreachable-code-return \
	-Wused-but-marked-unused \
	-Wno-undefined-var-template \
	-Wno-constant-conversion \
	-Wredundant-decls

include $(call select_from_repositories,lib/mk/android-lib.inc)

# For custom stdatomic.h
CC_OPT += -I$(call select_from_repositories,include/)

# Position independent library
CC_OPT += -fPIC

# Taken from build/art.go
CC_OPT += -DIMT_SIZE=43
CC_OPT += -DART_DEFAULT_GC_TYPE_IS_CMS
CC_OPT += -DART_FRAME_SIZE_LIMIT=1736
CC_OPT += -DART_BASE_ADDRESS_MIN_DELTA=-0x1000000
CC_OPT += -DART_BASE_ADDRESS_MAX_DELTA=0x1000000

# Taken from build/soong/android/config.go, Mips/Mips64 would be 0x5C000000
CC_OPT += -DART_BASE_ADDRESS=0x70000000

# Use compiler's definition of UINT64_C/INT64_C as a fallback
CC_OPT += -DUINT64_C=__UINT64_C
CC_OPT += -DINT64_C=__INT64_C

# Code contains multi-line comments
CC_OPT += -Wno-error=comment

# Prevent errors regarding hidden constructor for struct
# sigaction/sigaltstack/sigstack and sigvec
CC_OPT += -Wno-error=shadow

# FIXME: The _Atomic keyword is not available in the Genode toolchain
CC_OPT += -D_Atomic=

# FIXME: _Bool is not available
CC_OPT += -D_Bool=bool

# FIXME: __auto_type is not available
CC_OPT += -D__auto_type=auto

# O_CLOEXEC does not exist in FreeBSD libc
CC_OPT += -DO_CLOEXEC=0

# MAP_32BIT does not exist in FreeBSD libc
CC_OPT += -DMAP_32BIT=0

# pthread_getname_np does not exist on Genode.
CC_OPT += -D'pthread_getname_np(self,name,len)=(-1)'

CC_OPT += -I$(call select_from_repositories,src/lib/libart/include)

# Include path for generated asm_support_gen.h
# We don't generate it as it comes with the sources.
CC_OPT += -I$(call select_from_ports,libart)/art/runtime/generated

# For sigchain.h
CC_OPT += -I$(call select_from_ports,libart)/art/sigchainlib

# For cmdline_types.h
CC_OPT += -I$(call select_from_ports,libart)/art/cmdline

# For including "../../../external/dlmalloc/malloc.c" in dlmalloc.cc
# We use the .git directory as the include wants to go back 3 levels and
# this is the only directory inside the last dlmalloc dir.
CC_OPT += -I$(call select_from_ports,dlmalloc)/dlmalloc/external/dlmalloc/.git

#
# FIXME: SUPPRESS WARNINGS! DEVELOPMENT ONLY - REMOVE FOR PRODUCTION!
$(warning SUPPRESSING WARNINGS - REMOVE FOR PRODUCTION!)
CC_OPT+= -w

LIBS += valgrind dlmalloc zlib icu
