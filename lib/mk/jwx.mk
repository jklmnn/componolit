
include $(REP_DIR)/lib/import/import-jwx.mk

SRC_ADB = jwx-base64.adb \
	  jwx-crypto.adb \
	  jwx-jose.adb \
	  jwx-json.adb \
	  jwx-jwk.adb \
	  jwx-jws.adb \
	  jwx-jwscs.adb \
	  jwx-jwt.adb \
	  jwx-lsc.adb \
	  jwx-stream_auth.adb \
	  jwx-util.adb \
	  jwx.adb \

vpath %.adb $(JWX_DIR)

LIBS += ada libsparkcrypto
