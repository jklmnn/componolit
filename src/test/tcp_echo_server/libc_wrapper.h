
#include <libc/component.h>

#define LIBC(func, ...) Libc::with_libc([&] () { \
        lc_##func(__VA_ARGS__); \
        })

