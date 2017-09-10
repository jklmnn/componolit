TARGET = libutils_test

ANDROID_PORT	   = core
ANDROID_DIR		   = system/core/libutils/tests
ANDROID_SECTIONS   = /cc_test[@name=libutils_tests] /cc_test[@name=libutils_tests]/target/host


#/cc_test_library[@name=libutils_test_singleton1] /cc_test_library[@name=libutils_test_singleton2]


include $(call select_from_repositories,lib/mk/android-prg.inc)

SRC_CC += main.cc
CC_OPT += -Wno-error=unused-function
CC_OPT += -D'EXPECT_DEATH(a,b)'
CC_OPT += -D'ASSERT_DEATH(a,b)'

LIBS += gtest libfakeatomic libbacktrace

# FIXME: SUPPRESS WARNINGS! DEVELOPMENT ONLY - REMOVE FOR PRODUCTION!
$(warning SUPPRESSING WARNINGS - REMOVE FOR PRODUCTION!)
CC_OPT += -w
