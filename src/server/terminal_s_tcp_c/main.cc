
#include <libc/component.h>
#include <base/heap.h>
#include <base/attached_rom_dataspace.h>

#include <component.h>

namespace Terminal
{
    struct Main;
};

struct Terminal::Main
{
    Genode::Env &_env;
    Genode::Sliced_heap _heap {_env.ram(), _env.rm()};
    Genode::Attached_rom_dataspace _config {_env, "config"};

    Root_component _root {_env, _env.ep(), _heap, _env.ram(), _env.rm(),
        _config.xml().attribute_value<Genode::String<16>>("server_ip", "0.0.0.0"),
        static_cast<int>(_config.xml().attribute_value<long int>("server_port", 0))};

    Main(Genode::Env &env) : _env(env)
    {
        env.parent().announce(env.ep().manage(_root));
        Genode::log("terminal_tcp");
    }
};

void Libc::Component::construct(Libc::Env &env)
{
    static Terminal::Main main(env);
}
