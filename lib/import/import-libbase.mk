ANDROID_LIB := libbase
include $(call select_from_repositories,lib/import/import-android.inc)

CC_OPT += -Doff64_t=int64_t
