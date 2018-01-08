TARGET = baseband-fw
SRC_CC = main.cc fw.cc
SRC_ADA = baseband_fw.adb fw_log.adb fw_types.adb genode_log.adb
LIBS = base nic_filter
INC_DIR += $(PRG_DIR)

include $(REP_DIR)/mk/gnat_opts.mk
