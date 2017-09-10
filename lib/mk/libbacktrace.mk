INC_DIR += $(call select_from_ports,core)/system/core/include
vpath % $(call select_from_repositories,src/lib/libbacktrace)

LIBS += stdcxx
SRC_CC += backtrace.cc
SHARED_LIB = yes
