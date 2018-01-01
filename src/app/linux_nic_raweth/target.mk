TARGET = client-linux_nic_raweth
SRC_CC = main.cc ethernet.cc
LIBS = lx_hybrid

# FIXME: Should be factored out into library dir
SERVER_DIR = $(REP_DIR)/src/server/linux_nic_raweth

INC_DIR += $(SERVER_DIR)
vpath ethernet.cc $(SERVER_DIR)
