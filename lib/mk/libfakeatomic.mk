include $(call select_from_repositories,lib/import/import-libfakeatomic.mk)
vpath % $(call select_from_repositories,src/lib/libfakeatomic)

LIBS += stdcxx
SRC_CC += fakeatomic.cc
SHARED_LIB = yes
