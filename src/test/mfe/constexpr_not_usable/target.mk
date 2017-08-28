TARGET = constexpr_not_usable

CC_CXX_OPT_STD = -std=gnu++14
CC_OPT += -Werror=redundant-decls
SRC_CC = main.cc
LIBS   = posix stdcxx
