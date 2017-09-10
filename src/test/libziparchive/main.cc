/* Genode includes */
#include <libc/component.h>

/* libc includes */
#include <stdlib.h> /* 'exit'   */

extern int          genode_argc;
extern char const **genode_argv;

/* provided by the application */
extern "C" int main(int argc, char const **argv);

void Libc::Component::construct(Libc::Env &env)
{
	Libc::with_libc([&] {

		char const *argv[] = {
			"/bin/test_libziparchive",
			"--gtest_filter=-zipwriter.WriteCompressedZipFlushFull",
			"--test_data_dir=/",
			0
		};

		genode_argc = 3;
		genode_argv = argv;

		setprogname (genode_argv[0]);
		exit (main(genode_argc, genode_argv));
	});
}
