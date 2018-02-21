TARGET = sntp
LIBS = libc lwip libc_lwip_nic_dhcp libc_lwip
SRC_CC = main.cc client.cc libc_wrapper.cc
SRC_ADA = libc.adb sntp.adb

INC_DIR += $(PRG_DIR)

CC_CXX_WARN_STRICT =

