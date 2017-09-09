#include <atomic>
#undef ATOMIC_VAR_INIT
#include <stdatomic.h>

namespace std {

void __atomic_thread_fence (memory_order mo __attribute__((unused))) { };
void __atomic_signal_fence (memory_order mo __attribute__((unused))) { };

}
