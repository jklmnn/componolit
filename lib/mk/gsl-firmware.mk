#
# Pseudo library to copy gslx680 firmware to build directory
#

GSL_DIR := $(call select_from_ports,gsl-firmware)/gsl/firmware
BIN_DIR := $(BUILD_BASE_DIR)/bin
FILES := $(shell find $(GSL_DIR) -name silead_ts.fw)

all:
	$(foreach fw_file,$(FILES),$(shell cp $(fw_file) $(BIN_DIR)/$(shell sed "s|$(GSL_DIR)/||g;s|/|_|g" <<< $(fw_file))))

