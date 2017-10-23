
#include <filter.h>

Nic_filter::Filter::Filter(Genode::Env &env) :
    _heap(env.ram(), env.rm()),
    _root(env, _heap),
    _client(env)
{
    env.parent().announce(env.ep().manage(_root));
}
