
#include <base/component.h>
#include <base/heap.h>

#include <component.h>

extern "C" {

    void debug(char *msg)
    {
        Genode::log(Genode::Cstring(msg));
    }

}

namespace Http_Filter
{
    struct Main;
};

struct Http_Filter::Main
{
    Genode::Env &_env;
    Genode::Sliced_heap _heap { _env.ram(), _env.rm() };

    Root _root { _env, _env.ep(), _heap, _env.ram(), _env.rm() };

    Main(Genode::Env &env) : _env(env)
    {
        Genode::log("http_filter");
        env.parent().announce(env.ep().manage(_root));
    }
};

void Component::construct(Genode::Env &env)
{
    env.exec_static_constructors();
    static Http_Filter::Main main(env);
}
