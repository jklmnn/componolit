
#include <root/component.h>
#include <terminal_session/terminal_session.h>
#include <base/attached_ram_dataspace.h>

namespace Http_Filter
{
    class Root;
    class Component;
    enum {
        IO_BUFFER_SIZE = 4096
    };
};

class Http_Filter::Component : public Genode::Rpc_object<Terminal::Session, Component>
{
    private:

        Genode::Attached_ram_dataspace _io_buffer;

    public:

        Component(Genode::Env &,
                Genode::Ram_session &,
                Genode::Region_map &,
                Genode::size_t);

        Terminal::Session::Size size() override;
        bool avail() override;
        Genode::size_t _read(Genode::size_t);
        Genode::size_t _write(Genode::size_t);
        Genode::Dataspace_capability _dataspace();
        void read_avail_sigh(Genode::Signal_context_capability) override;
        void size_changed_sigh(Genode::Signal_context_capability) override;
        void connected_sigh(Genode::Signal_context_capability);
        Genode::size_t read(void *, Genode::size_t) override;
        Genode::size_t write(void const *, Genode::size_t) override;
};

class Http_Filter::Root : public Genode::Root_component<Component>
{
    private:

        Genode::Env &_env;
        Genode::Ram_session &_ram;
        Genode::Region_map &_rm;

    protected:

        Component *_create_session(const char *);

    public:

        Root(Genode::Env &,
                Genode::Entrypoint &,
                Genode::Allocator &,
                Genode::Ram_session &,
                Genode::Region_map &);
};
