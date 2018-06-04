
#include <libc/component.h>

#include <component.h>

#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netdb.h>

long (*libc_write)(int, const void *, Genode::size_t) = write;
long (*libc_read)(int, void *, Genode::size_t) = read;

Http_Filter::Component::Component(Genode::Env &env,
        Genode::Ram_session &ram,
        Genode::Region_map &rm,
        Genode::size_t io_buffer_size,
        const char *address,
        int port) :
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

            server = gethostbyname(address);
            serv.sin_family = AF_INET;
            Genode::memcpy(&(serv.sin_addr.s_addr), server->h_addr, server->h_length);
            serv.sin_port = htons(port);

            if(connect(_socket, (struct sockaddr *)&serv, sizeof(serv)) < 0){
            Genode::error("Failed to connect");
            }

            });
}

Terminal::Session::Size Http_Filter::Component::size()
{
    return Terminal::Session::Size(0, 0);
}

bool Http_Filter::Component::avail()
{
    return false;
}

Genode::size_t Http_Filter::Component::_read(Genode::size_t s)
{
    Genode::size_t const transfer = Genode::min(s, _io_buffer.size());
    int const received = libc_read(_socket, _io_buffer.local_addr<void>(), transfer);
    if (received < 1){
        if(_async_read.constructed()){
            _async_read->close();
            _async_read->join();
            _async_read.destruct();
        }
        close(_socket);
    }
    if (_read_sem.cnt() < 1){
        _read_sem.up();
    }
    return Genode::max(received, 0);
}

Genode::size_t Http_Filter::Component::_write(Genode::size_t s)
{
    int const sent = libc_write(_socket, _io_buffer.local_addr<void>(), Genode::min(s, _io_buffer.size()));
    if(sent < 1){
        close(_socket);
    }
    return Genode::max(sent, 0);
}

Genode::Dataspace_capability Http_Filter::Component::_dataspace()
{
    return _io_buffer.cap();
}

void Http_Filter::Component::read_avail_sigh(Genode::Signal_context_capability cap)
{
    char label[20] = {};
    snprintf(label, 20, "http_uplink_%d", _socket);
    if(_async_read.constructed()){
        _async_read.destruct();
    }
    _async_read.construct(_env, _socket, label, cap, _read_sem);
    _async_read->start();
}

void Http_Filter::Component::size_changed_sigh(Genode::Signal_context_capability)
{ }

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
        Genode::Region_map &rm,
        Genode::String<16> address,
        int port) :
    Genode::Root_component<Component>(&ep.rpc_ep(), &md_alloc),
    _env(env), _ram(ram), _rm(rm), _address(address), _port(port)
{ }

Http_Filter::Component *Http_Filter::Root::_create_session(const char *)
{
    Genode::size_t const io_buffer_size = 4096;
    return new (md_alloc()) Component(_env, _ram, _rm, io_buffer_size, _address.string(), _port);
}
