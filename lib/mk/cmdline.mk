ANDROID_PORT = libart
ANDROID_DIR = art
ANDROID_BUILDFILES = build/Android.bp test/Android.bp cmdline/Android.bp
ANDROID_SECTIONS = /art_cc_test[@name=art_cmdline_tests]

include $(call select_from_repositories,lib/mk/android-lib.inc)
