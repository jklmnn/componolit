/* Genode includes */
#include <libc/component.h>

/* libc includes */
#include <stdlib.h> /* 'exit'   */

#include <gtest/gtest.h>

extern int          genode_argc;
extern const char **genode_argv;

/* provided by the application */
extern "C" int main(int argc, char const **argv);

void Libc::Component::construct(Libc::Env &env)
{
	Libc::with_libc([&] {

		// Disabled tests:
		//
		// TestIpv6*: IPv6 is not supported
		// Test*ReceiveTimeout: Hangs. May be related to genode#2474, FIXME: Otherwise file issue based on test/mfe/sock_receive_timeout
		// android_get_control_socket: No PF_UNIX socket implementation. We may not need it or replace the code.
		// TestIpv4UdpLoopback: Related to [1]
		// TestIpv4TcpLoopback: getsockopt(..SO_ERROR..) issue, FIXME: File issue based on test/mfe/getsockopt_so_error
		// str_params.put_ENOMEM: They test for hashmapPut not being influence/not influencing errno being set to ENOMEM. However, unimplemented functions in Genodes libc set ENOMEM to 'Not implemented' inbetween. This makes the final assertion fail. We ignore this test.
		//
		//
		// [1] https://sourceforge.net/p/genode/mailman/message/35980126/
		char const *argv[] = {
			"/bin/test_libcutils",
			"--gtest_filter=-SocketsTest.TestIpv6*:SocketsTest.Test*ReceiveTimeout:SocketsTest.android_get_control_socket:SocketsTest.TestIpv4*Loopback:str_parms.put_ENOMEM",
			0
		};

		genode_argc = 2;
		genode_argv = argv;

		setprogname (genode_argv[0]);

		testing::InitGoogleTest(&genode_argc, (char **)genode_argv);
		exit(RUN_ALL_TESTS());
	});
}
