DLMALLOC_DIR = $(call select_from_ports,dlmalloc)/dlmalloc/external/dlmalloc

# For including "../../../external/dlmalloc/malloc.c" in dlmalloc.cc
# We use the .git directory as the include wants to go back 3 levels and
# this is the only directory inside the last dlmalloc dir.
INC_DIR += $(DLMALLOC_DIR)/.git

# For including "../../external/dlmalloc/malloc.c"
INC_DIR += $(DLMALLOC_DIR)
