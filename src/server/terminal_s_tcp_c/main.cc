
#include <libc/component.h>
#include <base/heap.h>

#include <component.h>

namespace Terminal
{
    struct Main;
};

struct Terminal::Main
{
    Genode::Sliced_heap _heap;

    Root_component _root;

    Main(Genode::Env &env) :
        _heap(env.ram(), env.rm()),
        _root(env.ep(), _heap, env.ram(), env.rm())
    {
        env.parent().announce(env.ep().manage(_root));
        Genode::log("terminal_tcp");
    }
};

void Libc::Component::construct(Libc::Env &env)
{
    static Terminal::Main main(env);
}
