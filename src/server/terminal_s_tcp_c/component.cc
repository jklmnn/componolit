
#include <component.h>

Terminal::Session_component::Session_component(Genode::Ram_session &ram, Genode::Region_map &rm) :
    _io_buffer(ram, rm, IO_BUFFER_SIZE),
    _read_avail(Genode::Signal_context_capability()),
    _unhandled(0)
{ }

Terminal::Session::Size Terminal::Session_component::size()
{
    return Terminal::Session::Size(0, 0);
}

bool Terminal::Session_component::avail()
{
    return (bool)_unhandled;
}

Genode::size_t Terminal::Session_component::_read(Genode::size_t size)
{
    Genode::size_t cpy = Genode::min(size, _unhandled);
    Genode::memcpy(_io_buffer.local_addr<void>(), _local_buffer, cpy);
    _unhandled -= cpy;
    return cpy;
}

Genode::size_t Terminal::Session_component::_write(Genode::size_t size)
{
    Genode::size_t cpy = Genode::min((unsigned)Genode::max((unsigned)0, IO_BUFFER_SIZE - _unhandled), size);
    if(cpy > 0){
        Genode::memcpy(_local_buffer, _io_buffer.local_addr<void>(), cpy);
        _unhandled += cpy;
    }
    Genode::Signal_transmitter(_read_avail).submit();
    return cpy;
}

Genode::Dataspace_capability Terminal::Session_component::_dataspace()
{
    return _io_buffer.cap();
}

void Terminal::Session_component::read_avail_sigh(Genode::Signal_context_capability cap)
{
    _read_avail = cap;
}

void Terminal::Session_component::size_changed_sigh(Genode::Signal_context_capability)
{ }

void Terminal::Session_component::connected_sigh(Genode::Signal_context_capability cap)
{
    Genode::log(__func__);
    Genode::Signal_transmitter(cap).submit();
}

Genode::size_t Terminal::Session_component::read(void *, Genode::size_t)
{
    Genode::warning(__func__, " not implemented");
    return 0;
}

Genode::size_t Terminal::Session_component::write(void const *, Genode::size_t)
{
    Genode::warning(__func__, " not implemented");
    return 0;
}

Terminal::Root_component::Root_component(Genode::Entrypoint &ep,
        Genode::Allocator &md_alloc,
        Genode::Ram_session &ram,
        Genode::Region_map &rm) :
    Genode::Root_component<Session_component>(&ep.rpc_ep(), &md_alloc),
    _ram(ram), _rm(rm)
{ }

Terminal::Session_component *Terminal::Root_component::_create_session(const char *)
{
    return new (md_alloc())Terminal::Session_component(_ram, _rm);
}
