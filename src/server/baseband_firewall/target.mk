TARGET = baseband-fw
SRC_CC = main.cc fw.cc
SRC_ADA = baseband_fw.adb
LIBS = base nic_filter
INC_DIR += $(PRG_DIR)
