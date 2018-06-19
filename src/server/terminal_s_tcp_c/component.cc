
#include <component.h>
#include <libc_wrapper.h>

#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netdb.h>
#include <sys/ioctl.h>

void lc_write(int fd, const void *buffer, Genode::size_t size, long *result)
{
    *result = write(fd, buffer, size);
}

void lc_read(int fd, void *buffer, Genode::size_t size, long *result)
{
    *result = read(fd, buffer, size);
}

void lc_close(int sock)
{
    close(sock);
}

Terminal::Session_component::Session_component(Genode::Env &, Genode::Ram_session &ram, Genode::Region_map &rm,
        Genode::String<16> address, int port) :
    _io_buffer(ram, rm, IO_BUFFER_SIZE),
    _read_avail(Genode::Signal_context_capability()),
    _unhandled(0),
    _address(address),
    _port(port),
    _socket(-1)
{ }

Terminal::Session::Size Terminal::Session_component::size()
{
    return Terminal::Session::Size(0, 0);
}

Terminal::Session_component::~Session_component()
{
    LIBC(close, _socket);
}

bool Terminal::Session_component::avail()
{
    int bytes = 0;
    LIBC(poll, &bytes);
    return (bool)bytes;
}

Genode::size_t Terminal::Session_component::_read(Genode::size_t size)
{
    long received;
    LIBC(read, _socket, _io_buffer.local_addr<void>(), Genode::min(size, (Genode::size_t)IO_BUFFER_SIZE), &received);
    return Genode::max(received, 0);
}

Genode::size_t Terminal::Session_component::_write(Genode::size_t size)
{
    long sent;
    LIBC(write, _socket, _io_buffer.local_addr<const void>(), Genode::min(size, (Genode::size_t)IO_BUFFER_SIZE), &sent);
    return Genode::max(sent, 0);
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
    Genode::log("Connecting to ", _address, ":", _port);
    if(_socket == -1){
        LIBC(connect);
    }
    if(_socket < 0){
        Genode::error("Failed to connect to ", _address, ":", _port);
    }else{
        Genode::Signal_transmitter(cap).submit();
    }
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

void Terminal::Session_component::lc_connect()
{
    struct sockaddr_in server;
    struct hostent *host;

    _socket = socket(AF_INET, SOCK_STREAM, 0);
    host = gethostbyname(_address.string());
    server.sin_family = AF_INET;
    Genode::memcpy(&(server.sin_addr.s_addr), host->h_addr, host->h_length);
    server.sin_port = htons(_port);

    if(connect(_socket, (struct sockaddr *)&server, sizeof(server)) < 0){
        Genode::error("connect failed");
        close(_socket);
        _socket = -1;
    }
}

void Terminal::Session_component::lc_poll(int *status)
{
    ioctl(_socket, FIONREAD, status);
}

Terminal::Root_component::Root_component(Genode::Env &env,
        Genode::Entrypoint &ep,
        Genode::Allocator &md_alloc,
        Genode::Ram_session &ram,
        Genode::Region_map &rm,
        Genode::String<16> address,
        int port) :
    Genode::Root_component<Session_component>(&ep.rpc_ep(), &md_alloc),
    _env(env), _ram(ram), _rm(rm), _address(address), _port(port)
{ }

Terminal::Session_component *Terminal::Root_component::_create_session(const char *)
{
    return new (md_alloc())Terminal::Session_component(_env, _ram, _rm, _address, _port);
}
