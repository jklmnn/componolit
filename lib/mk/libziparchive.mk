ANDROID_PORT	 = core
ANDROID_DIR  	     = system/core/libziparchive
ANDROID_EXCLUDE_LIBS = libz
ANDROID_SECTIONS     = /cc_library[@name=libziparchive] /cc_library[@name=libziparchive]/target/host

include $(call select_from_repositories,lib/mk/android-lib.inc)

LIBS += zlib
