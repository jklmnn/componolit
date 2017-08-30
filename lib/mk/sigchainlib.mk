ANDROID_PORT = libart
ANDROID_DIR = art
ANDROID_BUILDFILES = build/Android.bp sigchainlib/Android.bp
ANDROID_SECTIONS = /cc_library[@name=libsigchain]

include $(call select_from_repositories,lib/mk/android-lib.inc)
