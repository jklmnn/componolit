TARGET = redundant_op_redecl

CC_OPT += -Werror=redundant-decls
SRC_CC = main.cc
LIBS   = posix stdcxx
