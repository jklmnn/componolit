#include "runtime.h"
#include "runtime_common.h"

namespace art {

void HandleUnexpectedSignalGenode(int signal_number, siginfo_t* info, void* raw_context) {
	HandleUnexpectedSignalCommon(signal_number, info, raw_context, /* running_on_linux */ false);
	exit(EXIT_FAILURE);
}

void Runtime::InitPlatformSignalHandlers() {
  InitPlatformSignalHandlersCommon(HandleUnexpectedSignalGenode,
                                   nullptr,
                                   /* handle_timeout_signal */ true);
}

}
