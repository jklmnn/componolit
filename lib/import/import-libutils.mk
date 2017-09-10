ANDROID_LIB := libutils
include $(call select_from_repositories,lib/import/import-android.inc)

# ENODATA does not exist in FreeBSD's libc
CC_OPT += -DENODATA=ENOMSG

# off64_t not available in  FreeBSD's libc
CC_OPT += -Doff64_t=int64_t

# FIXME: __auto_type is not available
CC_OPT += -D__auto_type=auto

# Make dprintf available
CC_OPT += -D_WITH_DPRINTF

# Enable INT64_MAX
CC_OPT += -D__STDC_LIMIT_MACROS=1
