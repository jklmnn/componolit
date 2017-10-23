TARGET = nic_filter
SRC_CC = filter.cc \
	 session.cc \
	 root.cc
INC_DIR += $(PRG_DIR)
LIBS   = base
