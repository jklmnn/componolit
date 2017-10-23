
#include <filter.h>

Nic_filter::Filter::Filter(Genode::Env &env) :
    _heap(env.ram(), env.rm()),
    _root(env, _heap, this)
{
    env.parent().announce(env.ep().manage(_root));
}

void Nic_filter::Filter::update_buf_size(Genode::size_t rx, Genode::size_t tx)
{
    _rx_buf = rx;
    _tx_buf = tx;
}
