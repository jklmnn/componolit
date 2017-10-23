
#include <filter.h>

Nic_filter::Filter::Session::Session(
        Genode::size_t tx_buf_size,
        Genode::size_t rx_buf_size,
        Genode::Allocator &rx_block_md_alloc,
        Genode::Env &env,
        Nic_filter::Filter *filter) :
    Nic::Session_component(tx_buf_size, rx_buf_size, rx_block_md_alloc, env),
    _env( env ),
    _heap( _env.ram(), _env.rm() ),
    _tx_block_alloc( &_heap ),
    _nic( _env, &_tx_block_alloc, tx_buf_size, rx_buf_size),
    _nic_handler(_env.ep(), *this, &Session::_handle_nic),
    _filter(filter)
{
    _filter->update_buf_size(rx_buf_size, tx_buf_size);
}

Nic::Mac_address Nic_filter::Filter::Session::mac_address()
{
    char mac[6] = {1,1,1,1,1,1};
    return Nic::Mac_address { mac };
}

bool Nic_filter::Filter::Session::link_state()
{
    return true;
}

void Nic_filter::Filter::Session::_handle_packet_stream()
{
    
}

void Nic_filter::Filter::Session::_handle_nic()
{

}
