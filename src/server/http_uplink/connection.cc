
#include <connection.h>
#include <unistd.h>

Http_Filter::Connection::Connection(Genode::Env &env, int socket, Genode::String<32> label) :
    _env(env),
    _terminal(env, label.string()),
    _read_sigh(env.ep(), *this, &Http_Filter::Connection::handle_response),
    _socket(socket),
    _loop(env, socket, label, _terminal)
{
    Genode::log(__func__);
    _terminal.read_avail_sigh(_read_sigh);
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

void Http_Filter::Connection::start()
{
    _loop.start();
}

Http_Filter::Connection_loop::Connection_loop(Genode::Env &env, int socket, Genode::String<32> label,
        Terminal::Connection &terminal) :
    Genode::Thread(env, label.string(), BUFSIZE + 4096),
    _socket(socket),
    _terminal(terminal)
{ }

void Http_Filter::Connection_loop::entry()
{
    Genode::log("entry submit");
    char buffer[BUFSIZE];
    long size;

    while (size = read(_socket, buffer, BUFSIZE), size > 0){
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

