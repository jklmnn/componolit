$(warning INC: libfakeatomic)
LIBFAKEATOMIC_DIR = $(call select_from_repositories,src/lib/libfakeatomic)

# For custom stdatomic.h
INC_DIR += $(LIBFAKEATOMIC_DIR)/include

# FIXME: The _Atomic keyword is not available in the Genode toolchain
CC_OPT += -D_Atomic=

# FIXME: _Bool is not available
CC_OPT += -D_Bool=bool
