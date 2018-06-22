TARGET = http_filter
SRC_CC = main.cc component.cc
SRC_ADB = terminal-session.adb
LIBS = base ada jwx libsparkcrypto
INC_DIR += $(PRG_DIR) $(PRG_DIR)/include

CC_CXX_WARN_STRICT =

$(warning FIXME: Static keys use - DO NOT USE FOR PRODUCTION!!!)
