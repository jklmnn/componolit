
#include <connection.h>
#include <unistd.h>

Http_Filter::Connection::Connection(Genode::Env &env, int socket) :
    Genode::Thread(env, "test", 4096),
    _terminal(env, "test"),
    _read_sigh(env.ep(), *this, &Http_Filter::Connection::handle_response),
    _socket(socket)
{
    _terminal.read_avail_sigh(_read_sigh);
}

void Http_Filter::Connection::entry()
{
    char buffer[BUFSIZE];
    long size = 0;

    while (size = read(_socket, buffer, BUFSIZE), size >= 0){
        while(size > 0){
            size -= _terminal.write(buffer, size);
        }
    }

    //FIXME: notify parent thread that thread returned
}

void Http_Filter::Connection::handle_response()
{
    char buffer[BUFSIZE];
    Genode::size_t size = _terminal.read(buffer, BUFSIZE);
    long ssize;

    while(size > 0){
        ssize = write(_socket, buffer, size);
        if(ssize < 0){
            Genode::error("Failed to write: ", ssize);
            return;
        }
        size += ssize;
    }
}
