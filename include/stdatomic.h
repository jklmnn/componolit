#ifndef _COMPONOLIT_STDATOMIC_H_
#define _COMPONOLIT_STDATOMIC_H_

#include_next <stdatomic.h>

#ifdef __cplusplus
namespace std {
#endif

void __atomic_thread_fence (memory_order mo __attribute__((unused))); 
void __atomic_signal_fence (memory_order mo __attribute__((unused)));

#ifdef __cplusplus
}
#endif

#endif // _COMPONOLIT_STDATOMIC_H_
