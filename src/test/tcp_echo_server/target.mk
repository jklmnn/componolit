TARGET = test-tcp_echo_server
SRC_CC = main.cc server.cc connection.cc
LIBS = libc lwip libc_lwip_nic_dhcp libc_lwip
INC_DIR += $(PRG_DIR)
