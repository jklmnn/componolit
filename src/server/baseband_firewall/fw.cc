
#include <fw.h>
#include <base/log.h>
#include <util/string.h>

extern "C" {

void log(const char *msg)
{
    Genode::log(Genode::String<1024>(msg));
}

void warn(const char *msg)
{
    Genode::warning(Genode::String<1024>(msg));
}

void error(const char *msg)
{
    Genode::error(Genode::String<1024>(msg));
}

void __gnat_last_chance_handler()
{
    Genode::warning(__func__, " not implemented");
}

}
