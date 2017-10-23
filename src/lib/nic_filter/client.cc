
#include <filter.h>

Nic_filter::Filter::Client::Client(Genode::Env &env) :
    _env( env ),
    _heap( _env.ram(), _env.rm() ),
    _tx_block_alloc( &_heap ),
    _nic( _env, &_tx_block_alloc, BUF_SIZE, BUF_SIZE)
{}

void Nic_filter::Filter::Client::_handle_nic()
{}
