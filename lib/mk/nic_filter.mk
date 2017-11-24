SRC_CC = component.cc\
	 uplink.cc\
	 interface.cc

INC_DIR += $(REP_DIR)/src/lib/nic_filter

vpath %.cc $(REP_DIR)/src/lib/nic_filter
