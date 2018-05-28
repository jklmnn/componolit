
#include <libc/component.h>
#include <root/component.h>
#include <base/heap.h>
#include <base/attached_ram_dataspace.h>
#include <terminal_session/terminal_session.h>
#include <timer_session/connection.h>

#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netdb.h>

namespace Http_Filter
{
    struct Main;
    class Root;
    class Component;
};

long (*libc_write)(int, const void *, Genode::size_t) = write;

class Http_Filter::Component : public Genode::Rpc_object<Terminal::Session, Component>
{
    private:

        Genode::Attached_ram_dataspace _io_buffer;
        Genode::Signal_context_capability _sig_cap;
        Genode::Signal_handler<Component> _read_sigh;
        Timer::Connection _timer;
        int _socket;

        void read_select(){
            Genode::log(__func__);
            char c;
            int received = recv(_socket, &c, 1, MSG_PEEK);
            if(received > 0){
                Genode::Signal_transmitter(_sig_cap).submit();
            }
            _timer.trigger_once(0);
        }

    public:

        Component(Genode::Env &env,
                Genode::Ram_session &ram,
                Genode::Region_map &rm,
                Genode::size_t io_buffer_size) :
            _io_buffer(ram, rm, io_buffer_size),
            _sig_cap(Genode::Signal_context_capability()),
            _read_sigh(env.ep(), *this, &Component::read_select),
            _timer(env),
            _socket(-1)
        {
            struct sockaddr_in serv;
            struct hostent *server;

            Libc::with_libc([&] () {
                    _socket = socket(AF_INET, SOCK_STREAM, 0);

                    if(_socket < 0){
                        Genode::error("Failed to open socket");
                    }

                    server = gethostbyname("10.0.2.55");
                    serv.sin_family = AF_INET;
                    Genode::memcpy(&(serv.sin_addr.s_addr), server->h_addr, server->h_length);
                    serv.sin_port = htons(80);

                    if(connect(_socket, (struct sockaddr *)&serv, sizeof(serv)) < 0){
                        Genode::error("Failed to connect");
                    }

                    _timer.sigh(_read_sigh);
                    _timer.trigger_once(0);
                    });
        }

        Terminal::Session::Size size() override
        {
            return Terminal::Session::Size(0, 0);
        }

        bool avail() override
        {
            return false;
        }

        Genode::size_t _read(Genode::size_t s)
        {
            Genode::log(__func__, " ", s);
            return 0;
        }

        Genode::size_t _write(Genode::size_t s)
        {
            Genode::log(__func__, " ", s);
            Genode::log(Genode::Cstring(_io_buffer.local_addr<char>()));
            return libc_write((int)_socket, _io_buffer.local_addr<void>(), (Genode::size_t)s);
        }

        Genode::Dataspace_capability _dataspace()
        {
            return _io_buffer.cap();
        }

        void read_avail_sigh(Genode::Signal_context_capability cap) override
        {
            _sig_cap = cap;
        }

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

        Genode::Env &_env;
        Genode::Ram_session &_ram;
        Genode::Region_map &_rm;

    protected:

        Component *_create_session(const char *)
        {
            Genode::size_t const io_buffer_size = 4096;
            return new (md_alloc()) Component(_env, _ram, _rm, io_buffer_size);
        }

    public:

        Root(Genode::Env &env,
                Genode::Entrypoint &ep,
                Genode::Allocator &md_alloc,
                Genode::Ram_session &ram,
                Genode::Region_map &rm) :
            Genode::Root_component<Component>(&ep.rpc_ep(), &md_alloc),
            _env(env), _ram(ram), _rm(rm)
        { }
};

struct Http_Filter::Main
{
    Genode::Env &_env;
    Timer::Connection _timer;

    Genode::Sliced_heap _heap { _env.ram(), _env.rm() };

    Root _root { _env, _env.ep(), _heap, _env.ram(), _env.rm() };

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
