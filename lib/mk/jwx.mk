
include $(REP_DIR)/lib/import/import-jwx.mk

SRC_ADB = jwx-base64.adb \
	  jwx-json.adb \
	  jwx-jwk.adb \
	  jwx-util.adb

vpath %.adb $(JWX_DIR)

LIBS += ada
