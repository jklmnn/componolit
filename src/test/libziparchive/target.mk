TARGET = libziparchive_test

ANDROID_PORT	 = core
ANDROID_DIR		 = system/core/libziparchive
ANDROID_EXCLUDE_LIBS = libz
ANDROID_SECTIONS = /cc_test[@name=ziparchive-tests] /cc_test[@name=ziparchive-tests]/target/host

include $(call select_from_repositories,lib/mk/android-prg.inc)

SRC_CC += main.cc
LIBS   += gtest posix libziparchive zlib libutils libbacktrace

TESTDATA = bad_crc.zip declaredlength.zip dummy-update.zip large.zip valid.zip

$(TARGET): $(INSTALL_DIR)/testdata.tar

$(INSTALL_DIR)/testdata.tar:
	$(VERBOSE)tar cf $@ -C $(ANDROID_BASEDIR)/testdata/ $(TESTDATA)

clean:
	$(VERBOSE)rm testdata.tar
