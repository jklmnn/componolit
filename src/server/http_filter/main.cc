
#include <base/component.h>
#include <base/heap.h>

#include <component.h>

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
        env.parent().announce(env.ep().manage(_root));
    }
};

void Component::construct(Genode::Env &env)
{
    static Http_Filter::Main main(env);
}
