ANDROID_PORT = libart
ANDROID_DIR = art
ANDROID_INCLUDES = runtime runtime/arch
ANDROID_SOURCES = runtime
ANDROID_BUILDFILES = test/Android.bp build/Android.bp runtime/Android.bp
ANDROID_SECTIONS = \
	/art_cc_library[@name=libart] \
	/art_cc_library[@name=libart]/arch/$(ANDROID_ARCH) \
	/gensrcs[@name=art_operator_srcs]

include $(call select_from_repositories,lib/mk/libart-defaults.inc)
include $(call select_from_repositories,lib/mk/android-lib.inc)

BASEDIR = $(call select_from_ports,libart)/art/runtime
GENTOOL = $(BASEDIR)/$($(ANDROID_NAME)_TOOL_FILES)
HEADERS = $(addprefix $(BASEDIR)/,$(filter %.h,$($(ANDROID_NAME)_SRCS)))
OUTPUT  = $($(ANDROID_NAME)_OUTPUT_EXTENSION)
GENDIR  = $(LIB_CACHE_DIR)/$(ANDROID_BUILDTYPE)/$(ANDROID_NAME)

$(GENDIR)/$(OUTPUT): $(HEADERS)
	$(VERBOSE)$(GENTOOL) $(HEADERS) > $@.tmp
	$(VERBOSE)mv $@.tmp $@

vpath %.cc $(GENDIR)
SRC_C += $(OUTPUT)

#
# FIXME: SUPPRESS WARNINGS! DEVELOPMENT ONLY - REMOVE FOR PRODUCTION!
$(warning SUPPRESSING WARNINGS - REMOVE FOR PRODUCTION!)
CC_OPT += -w

LIBS += valgrind dlmalloc zlib icu sigchainlib cmdline libziparchive libfakeatomic
