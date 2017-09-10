/* Genode includes */
#include <libc/component.h>

/* libc includes */
#include <stdlib.h> /* 'exit'   */

#include <gtest/gtest.h>

void Libc::Component::construct(Libc::Env &env)
{
	Libc::with_libc([&] {

		char const *argv[] = {
			"/bin/test_libutils",
			"--gtest_filter=-SingletonTest.bug35674422",
			0
		};
		int argc = 2;

		setprogname ("/bin/test_libutils");
		testing::InitGoogleTest(&argc, (char **)argv);
		exit (RUN_ALL_TESTS());
	});
}
