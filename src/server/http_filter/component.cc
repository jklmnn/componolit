
#include <component.h>

Http_Filter::Component::Component(Genode::Env &env,
        Genode::Ram_session &ram,
        Genode::Region_map &rm,
        Genode::size_t io_buffer_size) :
    _io_buffer(ram, rm, io_buffer_size),
    _terminal(env, "term"),
    _read_sig(Genode::Signal_context_capability()),
    _read_sigh(env.ep(), *this, &Http_Filter::Component::_handle_read),
    _authenticated(0),
    _available(false)
{
    Genode::log("_io_buffer ", sizeof(_io_buffer));
    Genode::log("_terminal ", sizeof(_terminal));
    Genode::log("_read_sig", sizeof(_read_sig));
    Genode::log("_read_sigh", sizeof(_read_sigh));
    Genode::log("_authenticated ", _authenticated);
    Genode::log("*this ", sizeof(*this));
    Genode::log(_io_buffer.local_addr<void>());
}

Terminal::Session::Size Http_Filter::Component::size()
{
    return _terminal.size();
}

bool Http_Filter::Component::avail()
{
    if (_available) {
       return true;
    }
    if (_authenticated) {
       return _terminal.avail();
    }
    return false;
}

/*
Genode::size_t Http_Filter::Component::_read(Genode::size_t)
{
    Genode::warning(__func__);
    return 0;
}

Genode::size_t Http_Filter::Component::_write(Genode::size_t size)
{
    Genode::warning(__func__);
    return _terminal.write(_io_buffer.local_addr<void>(), size);
}
*/

Genode::size_t Http_Filter::Component::cpp_write(Genode::size_t size, void *buffer)
{
    //Genode::log(__func__);
    return _terminal.write(buffer, size);
}

Genode::size_t Http_Filter::Component::cpp_read(Genode::size_t size, void *buffer)
{
    //Genode::log(__func__);
    return _terminal.read(buffer, size);
}

Genode::Dataspace_capability Http_Filter::Component::_dataspace()
{
    return _io_buffer.cap();
}

void Http_Filter::Component::read_avail_sigh(Genode::Signal_context_capability cap)
{
    Genode::warning(__func__);
    _read_sig = cap;
    _terminal.read_avail_sigh(_read_sigh);
}

void Http_Filter::Component::_transmit()
{
    Genode::warning(__func__);
    Genode::Signal_transmitter (_read_sig).submit();
}

void Http_Filter::Component::_handle_read()
{
    Genode::warning(__func__);
    if (_authenticated){
       _transmit();
    }
}

void Http_Filter::Component::size_changed_sigh(Genode::Signal_context_capability)
{
    Genode::warning(__func__);
}

void Http_Filter::Component::connected_sigh(Genode::Signal_context_capability cap)
{
    Genode::Signal_transmitter(cap).submit();
}

Genode::size_t Http_Filter::Component::read(void *, Genode::size_t)
{
    Genode::warning(__func__);
    return 0;
}

Genode::size_t Http_Filter::Component::write(void const *, Genode::size_t)
{
    Genode::warning(__func__);
    return 0;
}

Http_Filter::Root::Root(Genode::Env &env,
        Genode::Entrypoint &ep,
        Genode::Allocator &md_alloc,
        Genode::Ram_session &ram,
        Genode::Region_map &rm) :
    Genode::Root_component<Component>(&ep.rpc_ep(), &md_alloc),
    _env(env), _ram(ram), _rm(rm)
{ }

Http_Filter::Component *Http_Filter::Root::_create_session(const char *)
{
    return new (md_alloc()) Component(_env, _ram, _rm, IO_BUFFER_SIZE);
}
