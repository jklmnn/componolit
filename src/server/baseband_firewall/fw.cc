// Genode includes
#include <base/log.h>
#include <util/string.h>

// Local includes
#include <fw.h>

extern "C" {

void genode_log__log(const char *msg)
{
    Genode::log(Genode::Cstring(msg));
}

void genode_log__warn(const char *msg)
{
    Genode::warning(Genode::Cstring(msg));
}

void genode_log__error(const char *msg)
{
    Genode::error(Genode::Cstring(msg));
}

void genode_log__log_int(const int num)
{
    Genode::log("num: ", num);
}

void __gnat_last_chance_handler()
{
    Genode::error(__func__, " called");
    throw Genode::Exception();
}

}
