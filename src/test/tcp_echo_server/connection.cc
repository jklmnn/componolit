
#include <connection.h>

#include <unistd.h>

static char const response[] = "HTTP/1.0 200 OK\nServer: tcpecho\nContent-Type: text/html\nContent-Length: 9\nConnection: Keep-Alive\n\n<html/>\n";

Tcp::Connection::Connection(Genode::Env &env, int socket, char const *label) :
    Genode::Thread(env, label, CONNECTION_BUFFER + 4096),
    _socket(socket),
    _closed(false)
{
}

void Tcp::Connection::entry()
{
    char buffer[CONNECTION_BUFFER];
    long received, sent;

    while(!_closed){
        Genode::memset(buffer, 0, sizeof(buffer));
        sent = 0;
        received = 0;
        LIBC(read, buffer, sizeof(buffer), &received);
        Genode::log(Genode::Cstring(buffer));
        if(received > 0 && !_closed){
            while(sent < (int)sizeof(response) && !_closed){
                LIBC(write, &response[sent], sizeof(response) - sent, &sent);
            }
        }
    }
}

bool Tcp::Connection::closed() const
{
    return _closed;
}

void Tcp::Connection::lc_read(void *buffer, Genode::size_t size, long *result)
{
    *result += read(_socket, buffer, size);
    Genode::log(__func__, " ", *result);
    if(*result < 1){
        LIBC(close);
    }
}

void Tcp::Connection::lc_write(void const *buffer, Genode::size_t size, long *result)
{
    *result += write(_socket, buffer, size);
    Genode::log(__func__, " ", *result);
    if(*result < 1){
        LIBC(close);
    }
}

void Tcp::Connection::lc_close()
{
    _closed = true;
    close(_socket);
}
