
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
    _nic.rx_channel()->sigh_packet_avail(_nic_handler);
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
    while(_rx.source()->ack_avail()){
        Nic::Packet_descriptor packet = _rx.source()->get_acked_packet();
        _rx.source()->release_packet(packet);
    }
    while(_tx.sink()->packet_avail()){
        try{
            Nic::Packet_descriptor packet = _tx.sink()->get_packet();
            _filter->from_server(_tx.sink()->packet_content(packet), packet.size(), packet.offset(), this);
            _tx.sink()->acknowledge_packet(packet);
        } catch ( ... ) {
            Genode::warning(__func__, " dropped packet");
            break;
        }
    }
}

void Nic_filter::Filter::Session::_handle_nic()
{
    while(_nic.tx()->ack_avail()){
        Nic::Packet_descriptor packet = _nic.tx()->get_acked_packet();
        _nic.tx()->release_packet(packet);
    }
    while(_nic.rx()->packet_avail()){
        try {
            Nic::Packet_descriptor packet = _nic.rx()->get_packet();
            _filter->from_client(_nic.rx()->packet_content(packet), packet.size(), packet.offset(), this);
            _nic.rx()->acknowledge_packet(packet);
        } catch ( ... ) {
            Genode::warning(__func__, " dropped packet");
            break;
        }
    }
}

Nic::Packet_descriptor Nic_filter::Filter::Session::get_client_buffer(char **buffer, Genode::size_t size, Genode::off_t offset)
{
    Nic::Packet_descriptor packet = _nic.tx()->alloc_packet(size);
    *buffer = _nic.tx()->packet_content(packet);
    packet = Nic::Packet_descriptor(offset, size);
    return packet;
}

Nic::Packet_descriptor Nic_filter::Filter::Session::get_server_buffer(char **buffer, Genode::size_t size, Genode::off_t offset)
{
    Nic::Packet_descriptor packet = _rx.source()->alloc_packet(size);
    *buffer = _rx.source()->packet_content(packet);
    packet = Nic::Packet_descriptor(offset, size);
    return packet;
}

void Nic_filter::Filter::Session::to_client(Nic::Packet_descriptor packet)
{
    _nic.tx()->submit_packet(packet);
}

void Nic_filter::Filter::Session::to_server(Nic::Packet_descriptor packet)
{
    _rx.source()->submit_packet(packet);
}
