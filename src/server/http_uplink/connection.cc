
#include <connection.h>
#include <unistd.h>

Http_Filter::Connection::Connection(Genode::Env &env, int socket, Genode::String<32> label) :
    Genode::Thread(env, label.string(), BUFSIZE + 4096),
    _env(env),
    _terminal(env, label.string()),
    _read_sigh(env.ep(), *this, &Http_Filter::Connection::handle_response),
    _socket(socket)
{
    Genode::log(__func__);
    _terminal.read_avail_sigh(_read_sigh);
    Genode::Signal_transmitter(_read_sigh).submit();
}

void Http_Filter::Connection::entry()
{
    Genode::log("entry submit");
    Genode::Signal_handler<Connection> sigh(_env.ep(), *this, &Connection::handle_response);
    Genode::Signal_transmitter(sigh).submit();
    char buffer[BUFSIZE];
    long size = 0;

    while (size = read(_socket, buffer, BUFSIZE), size >= 0){
        Genode::log("read ", size);
        while(size > 0){
            Genode::warning("write loop");
            size -= _terminal.write(buffer, size);
        }
    }
    close(_socket);
    Genode::log("Closing connection");
    //FIXME: notify parent thread that thread returned
}

void Http_Filter::Connection::handle_response()
{
    Genode::error(__func__);
    char buffer[BUFSIZE];
    Genode::size_t size = _terminal.read(buffer, BUFSIZE);
    long ssize;

    while(size > 0){
        Genode::log("write ", size);
        ssize = write(_socket, buffer, size);
        if(ssize < 0){
            Genode::error("Failed to write: ", ssize);
            return;
        }
        size -= ssize;
    }
}
