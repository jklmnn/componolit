# identify the qt5 repository by searching for a file that is unique for qt5
QT5_REP_DIR := $(call select_from_repositories,lib/import/import-qt5.inc)
QT5_REP_DIR := $(realpath $(dir $(QT5_REP_DIR))../..)
include $(QT5_REP_DIR)/lib/mk/qt5_version.inc
QT5_CONTRIB_DIR := $(call select_from_ports,qt5)/src/lib/qt5/$(QT5)

include $(QT5_REP_DIR)/src/app/qt5/tmpl/target_defaults.inc

include $(QT5_REP_DIR)/src/app/qt5/tmpl/target_final.inc

LIBS 	+= qoost qt5_component qt5_qtvirtualkeyboardplugin
#INC_DIR	+= $(QT5_CONTRIB_DIR)/qtvirtualkeyboard/src/virtualkeyboard/\
	   $(QT5_CONTRIB_DIR)/qtbase/include/QtCore/5.8.0/
