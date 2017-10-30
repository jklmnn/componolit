SRC_CC = filter.cc \
	 session.cc \
	 root.cc

INC_DIR += $(REP_DIR)/src/lib/nic_filter

vpath %.cc $(REP_DIR)/src/lib/nic_filter
