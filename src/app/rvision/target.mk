# identify the qt5 repository by searching for a file that is unique for qt5
QT5_REP_DIR := $(call select_from_repositories,lib/import/import-qt5.inc)
QT5_REP_DIR := $(realpath $(dir $(QT5_REP_DIR))../..)

include $(QT5_REP_DIR)/lib/mk/qt5_version.inc

RVISION_CONTRIB_DIR := $(call select_from_ports,rvision)/rvision

QMAKE_PROJECT_PATH = $(RVISION_CONTRIB_DIR)
QMAKE_PROJECT_FILE = $(QMAKE_PROJECT_PATH)/rvision.pro

vpath % $(QMAKE_PROJECT_PATH)

include $(QT5_REP_DIR)/src/app/qt5/tmpl/target_defaults.inc

include $(QT5_REP_DIR)/src/app/qt5/tmpl/target_final.inc

LIBS += qt5_component qt5_windowplugin
