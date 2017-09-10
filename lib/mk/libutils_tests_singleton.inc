ANDROID_PORT	 = core
ANDROID_DIR  	 = system/core/libutils/tests
ANDROID_SECTIONS = /cc_test_library[@name=libutils_tests_singleton$(LIBNUM)]

LIBS += libutils libcore_includes libfakeatomic

include $(call select_from_repositories,lib/mk/android-lib.inc)
