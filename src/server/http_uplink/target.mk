TARGET = http_uplink
LIBS = libc lwip_legacy libc_lwip_nic_dhcp libc_lwip
SRC_CC = main.cc connection.cc server.cc

INC_DIR += $(PRG_DIR)

