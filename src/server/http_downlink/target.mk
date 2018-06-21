TARGET = http_downlink
LIBS = libc lwip_legacy libc_lwip_nic_dhcp libc_lwip
SRC_CC = main.cc component.cc async.cc

INC_DIR += $(PRG_DIR)
