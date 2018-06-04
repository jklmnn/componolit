
#include <libc/component.h>
#include <root/component.h>
#include <base/heap.h>
#include <base/attached_ram_dataspace.h>
#include <base/thread.h>
#include <terminal_session/terminal_session.h>
#include <timer_session/connection.h>

#include <stdio.h>
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
    class Async_Read;
};

long (*libc_write)(int, const void *, Genode::size_t) = write;
long (*libc_read)(int, void *, Genode::size_t) = read;

class Http_Filter::Async_Read : public Genode::Thread
{
    private:

        int _socket;
        bool _closed;
        Genode::Signal_context_capability _sig_cap;
        Genode::Semaphore &_sem;

        void entry()
        {
            Genode::log(__func__, " read thread ", _socket);
            char dummy;
            while(!_closed){
                recv(_socket, &dummy, 0, MSG_PEEK);
                Genode::log("submit: ", _sig_cap);
                Genode::Signal_transmitter(_sig_cap).submit();
                Genode::log("sem down");
                _sem.down();
                Genode::log("sem up");
            }
            Genode::log("socket closed");
        }

    public:
        Async_Read(Genode::Env &env, int sock, const char *label, Genode::Signal_context_capability sig,
                Genode::Semaphore &sem) :
            Genode::Thread(env, label, 4096),
            _socket(sock),
            _closed(false),
            _sig_cap(sig),
            _sem(sem)
    {}

        void close()
        {
            _closed = true;
            _sem.up();
        }

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
                Genode::size_t io_buffer_size) :
            _env(env),
            _io_buffer(ram, rm, io_buffer_size),
            _socket(-1),
            _async_read(),
            _read_sem(0)
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
            Genode::size_t const transfer = Genode::min(s, _io_buffer.size());
            int const received = libc_read(_socket, _io_buffer.local_addr<void>(), transfer);
            if (received < 1){
                if(_async_read.constructed()){
                    Genode::log("destructing");
                    _async_read->close();
                    _async_read->join();
                    _async_read.destruct();
                }
                close(_socket);
            }
            if (_read_sem.cnt() < 1){
                _read_sem.up();
            }
            Genode::log(__func__, " ", received, " return");
            return Genode::max(received, 0);
        }

        Genode::size_t _write(Genode::size_t s)
        {
            Genode::log(__func__, " ", s, " ", _socket);
            Genode::log(Genode::Cstring(_io_buffer.local_addr<char>()));
            int const sent = libc_write(_socket, _io_buffer.local_addr<void>(), Genode::min(s, _io_buffer.size()));
            if(sent < 1){
                close(_socket);
                Genode::log("socket closed (send)");
            }
            return Genode::max(sent, 0);
        }

        Genode::Dataspace_capability _dataspace()
        {
            return _io_buffer.cap();
        }

        void read_avail_sigh(Genode::Signal_context_capability cap) override
        {
            Genode::log(__func__, " ", cap);
            char label[20] = {};
            snprintf(label, 20, "http_uplink_%d", _socket);
            if(_async_read.constructed()){
                _async_read.destruct();
            }
            _async_read.construct(_env, _socket, label, cap, _read_sem);
            _async_read->start();
        }

        void size_changed_sigh(Genode::Signal_context_capability) override
        {}

        void connected_sigh(Genode::Signal_context_capability sigh)
        {
            Genode::Signal_transmitter(sigh).submit();
        }

        Genode::size_t read(void *, Genode::size_t) override
        {
            Genode::warning(__func__);
            return 0;
        }

        Genode::size_t write(void const *, Genode::size_t) override
        {
            Genode::warning(__func__);
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
