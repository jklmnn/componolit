
#include <connection.h>
#include <unistd.h>

Http_Filter::Connection::Connection(Genode::Env &env, int socket, Genode::String<32> label,
        Genode::Signal_context_capability close) :
    _env(env),
    _terminal(env, label.string()),
    _read_sigh(env.ep(), *this, &Http_Filter::Connection::handle_response),
    _close_sigh(env.ep(), *this, &Http_Filter::Connection::handle_close),
    _close_signal(close),
    _socket(socket),
    _closed(false),
    _loop(env, socket, label, _terminal, _closed, _close_sigh)
{
    _terminal.read_avail_sigh(_read_sigh);
}

void Http_Filter::Connection::handle_response()
{
    char buffer[BUFSIZE];
    Genode::size_t size = _terminal.read(buffer, BUFSIZE);
    long ssize;

    if(size == 0){
        Genode::Signal_transmitter(_close_sigh).submit();
    }

    while(size > 0){
        ssize = write(_socket, buffer, size);
        if(ssize < 0){
            Genode::error("Failed to write: ", ssize);
            return;
        }
        size -= ssize;
    }
}

void Http_Filter::Connection::handle_close()
{
    _closed = true;
    _loop.cancel_blocking();
    _loop.join();
    Genode::Signal_transmitter(_close_signal).submit();
}

void Http_Filter::Connection::start()
{
    _loop.start();
}

bool Http_Filter::Connection::closed() const
{
    return _closed;
}

void Http_Filter::Connection::join()
{
    close(_socket);
}

Http_Filter::Connection_loop::Connection_loop(Genode::Env &env, int socket, Genode::String<32> label,
        Terminal::Connection &terminal, bool &closed, Genode::Signal_context_capability csigh) :
    Genode::Thread(env, label.string(), BUFSIZE + 4096),
    _socket(socket),
    _closed(closed),
    _terminal(terminal),
    _csigh(csigh)
{ }

void Http_Filter::Connection_loop::entry()
{
    char buffer[BUFSIZE];
    long size, tsize;

    while (size = read(_socket, buffer, BUFSIZE), !_closed && size > 0){
        while(size > 0){
            tsize = _terminal.write(buffer, size);
            size -= tsize;
            if(tsize == 0){
                Genode::Signal_transmitter(_csigh).submit();
                break;
            }
        }
    }
}
