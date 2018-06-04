
#include <root/component.h>
#include <terminal_session/terminal_session.h>
#include <base/attached_ram_dataspace.h>

#include <async.h>

namespace Http_Filter
{
    class Root;
    class Component;
};


class Http_Filter::Component : public Genode::Rpc_object<Terminal::Session, Component>
{
    private:

        Genode::Env &_env;
        Genode::Attached_ram_dataspace _io_buffer;
        int _socket;
        Genode::Constructible<Async_Read> _async_read;
        Genode::Semaphore _read_sem;

    public:

        Component(Genode::Env &env,
                Genode::Ram_session &ram,
                Genode::Region_map &rm,
                Genode::size_t io_buffer_size,
                const char *,
                int);

        Terminal::Session::Size size() override;

        bool avail() override;

        Genode::size_t _read(Genode::size_t);

        Genode::size_t _write(Genode::size_t s);

        Genode::Dataspace_capability _dataspace();

        void read_avail_sigh(Genode::Signal_context_capability cap) override;

        void size_changed_sigh(Genode::Signal_context_capability) override;

        void connected_sigh(Genode::Signal_context_capability sigh);

        Genode::size_t read(void *, Genode::size_t) override;

        Genode::size_t write(void const *, Genode::size_t) override;

};

class Http_Filter::Root : public Genode::Root_component<Component>
{
    private:

        Genode::Env &_env;
        Genode::Ram_session &_ram;
        Genode::Region_map &_rm;
        Genode::String<16> _address;
        int _port;

    protected:

        Component *_create_session(const char *label);

    public:

        Root(Genode::Env &env,
                Genode::Entrypoint &ep,
                Genode::Allocator &md_alloc,
                Genode::Ram_session &ram,
                Genode::Region_map &rm,
                Genode::String<16> address,
                int port);
};
