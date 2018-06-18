
#include <connection.h>

Tcp::Connection::Connection(Genode::Env &env, int socket, char const *label) :
    Genode::Thread(env, label, CONNECTION_BUFFER + 4096),
    _socket(socket),
    _closed(false)
{ }

void Tcp::Connection::entry()
{
    Genode::log(__func__);
    _closed = true;
}

bool Tcp::Connection::closed() const
{
    return _closed;
}
