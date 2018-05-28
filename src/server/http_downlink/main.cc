
#include <libc/component.h>
#include <root/component.h>
#include <base/heap.h>
#include <base/attached_ram_dataspace.h>
#include <terminal_session/terminal_session.h>
#include <timer_session/connection.h>

namespace Http_Filter
{
    struct Main;
    class Root;
    class Component;
};

class Http_Filter::Component : public Genode::Rpc_object<Terminal::Session, Component>
{
    private:

        Genode::Attached_ram_dataspace _io_buffer;

    public:

        Component(Genode::Ram_session &ram,
                Genode::Region_map &rm,
                Genode::size_t io_buffer_size) :
            _io_buffer(ram, rm, io_buffer_size)
        { }

        Terminal::Session::Size size() override
        {
            return Terminal::Session::Size(0, 0);
        }

        bool avail() override
        {
            return false;
        }

        Genode::size_t _read(Genode::size_t size)
        {
            Genode::log(__func__, " ", size);
            return 0;
        }

        Genode::size_t _write(Genode::size_t size)
        {
            Genode::log(__func__, " ", size);
            Genode::log(Genode::Cstring(_io_buffer.local_addr<char>()));
            return size;
        }

        Genode::Dataspace_capability _dataspace()
        {
            return _io_buffer.cap();
        }

        void read_avail_sigh(Genode::Signal_context_capability) override
        {}

        void size_changed_sigh(Genode::Signal_context_capability) override
        {}

        void connected_sigh(Genode::Signal_context_capability sigh)
        {
            Genode::Signal_transmitter(sigh).submit();
        }

        Genode::size_t read(void *, Genode::size_t) override
        {
            return 0;
        }

        Genode::size_t write(void const *, Genode::size_t) override
        {
            return 0;
        }

};

class Http_Filter::Root : public Genode::Root_component<Component>
{
    private:

        Genode::Ram_session &_ram;
        Genode::Region_map &_rm;

    protected:

        Component *_create_session(const char *)
        {
            Genode::size_t const io_buffer_size = 4096;
            return new (md_alloc()) Component(_ram, _rm, io_buffer_size);
        }

    public:

        Root(Genode::Entrypoint &ep,
                Genode::Allocator &md_alloc,
                Genode::Ram_session &ram,
                Genode::Region_map &rm) :
            Genode::Root_component<Component>(&ep.rpc_ep(), &md_alloc),
            _ram(ram), _rm(rm)
        { }
};

struct Http_Filter::Main
{
    Genode::Env &_env;
    Timer::Connection _timer;

    Genode::Sliced_heap _heap { _env.ram(), _env.rm() };

    Root _root { _env.ep(), _heap, _env.ram(), _env.rm() };

    Main(Genode::Env &env) : _env(env), _timer(env)
    {
        Genode::log("http_downlink");
        _timer.msleep(6000);
        env.parent().announce(env.ep().manage(_root));
    }
};

void Libc::Component::construct(Libc::Env &env)
{
    static Http_Filter::Main main(env);
}
