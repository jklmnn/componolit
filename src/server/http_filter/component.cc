
#include <component.h>

Http_Filter::Component::Component(Genode::Env &,
        Genode::Ram_session &ram,
        Genode::Region_map &rm,
        Genode::size_t io_buffer_size) :
    _io_buffer(ram, rm, io_buffer_size)
{ }

Terminal::Session::Size Http_Filter::Component::size()
{
    return Terminal::Session::Size(0, 0);
}

bool Http_Filter::Component::avail()
{
    return false;
}

Genode::size_t Http_Filter::Component::_read(Genode::size_t)
{
    Genode::warning(__func__);
    return 0;
}

Genode::size_t Http_Filter::Component::_write(Genode::size_t)
{
    Genode::warning(__func__);
    return 0;
}

Genode::Dataspace_capability Http_Filter::Component::_dataspace()
{
    return _io_buffer.cap();
}

void Http_Filter::Component::read_avail_sigh(Genode::Signal_context_capability)
{
    Genode::warning(__func__);
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
