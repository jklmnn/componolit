
#include <root/component.h>
#include <terminal_session/terminal_session.h>
#include <base/attached_ram_dataspace.h>
#include <timer_session/connection.h>
#include <base/signal.h>

namespace Terminal
{
    class Session_component;
    class Root_component;
    enum {
        IO_BUFFER_SIZE = 4096,
        POLLING_TIME = 100000
    };
};

class Terminal::Session_component : public Genode::Rpc_object<Session, Session_component>
{
    private:

        Genode::Attached_ram_dataspace _io_buffer;
        Genode::Signal_context_capability _read_avail;
        char _local_buffer[IO_BUFFER_SIZE];
        unsigned _unhandled;
        Genode::String<16> _address;
        int _port;
        int _socket;
        Timer::Connection _timer;
        Genode::Signal_handler<Session_component> _poll_sigh;

        void lc_connect();
        void lc_poll(int *);
        void poll();

    public:

        Session_component(Genode::Env &, Genode::Ram_session &, Genode::Region_map &, Genode::String<16>, int);
        ~Session_component();

        Session::Size size() override;
        bool avail() override;

        Genode::size_t _read(Genode::size_t);
        Genode::size_t _write(Genode::size_t);

        Genode::Dataspace_capability _dataspace();

        void read_avail_sigh(Genode::Signal_context_capability);
        void size_changed_sigh(Genode::Signal_context_capability);
        void connected_sigh(Genode::Signal_context_capability);

        Genode::size_t read(void *, Genode::size_t);
        Genode::size_t write(void const *, Genode::size_t);
};

class Terminal::Root_component : public Genode::Root_component<Session_component>
{
    private:

        Genode::Env &_env;
        Genode::Ram_session &_ram;
        Genode::Region_map &_rm;
        Genode::String<16> _address;
        int _port;

    protected:

        Session_component *_create_session(const char *);

    public:

        Root_component(Genode::Env &,
                Genode::Entrypoint &,
                Genode::Allocator &,
                Genode::Ram_session &,
                Genode::Region_map &,
                Genode::String<16>,
                int);

};
