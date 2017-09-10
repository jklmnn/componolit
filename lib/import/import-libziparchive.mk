ANDROID_LIB := libziparchive
include $(call select_from_repositories,lib/import/import-android.inc)

# lseek64 is not supported in FreeBSD's libc
CC_OPT += -Dlseek64=lseek

# pread64 is not supported in FreeBSD's libc
CC_OPT += -Dpread64=pread

# UINT16_MAX not available
CC_OPT += -DUINT16_MAX=0xffff
