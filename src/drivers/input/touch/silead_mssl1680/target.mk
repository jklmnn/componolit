TARGET = silead_ts
LIBS = base acpica gsl-firmware
REQUIRES := x86
SRC_CC = main.cc acpi_gsl.cc gslx680.cc i2c_designware.cc gpio_gsl.cc
INC_DIR += $(PRG_DIR)/include
