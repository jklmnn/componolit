#include <base/log.h>

#include "thread.h"

namespace art {

void Thread::SetUpAlternateSignalStack() {
	Genode::log("SetUpAlternateSignalStack() called");
}
void Thread::TearDownAlternateSignalStack() {
	Genode::log("TearDownAlternateSignalStack() called");
}

void Thread::SetNativePriority(int) {
	// Do nothing.
}

int Thread::GetNativePriority() {                                                                                                              
  return kNormThreadPriority;
}

}
