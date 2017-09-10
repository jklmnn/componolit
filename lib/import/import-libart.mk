ANDROID_LIB := libart
include $(call select_from_repositories,lib/import/import-android.inc)
INC_DIR += $(call select_from_repositories,src/lib/libart/include)
