
#include <async.h>

#include <sys/types.h>
#include <sys/socket.h>

Http_Filter::Async_Read::Async_Read(Genode::Env &env, int sock, const char *label, Genode::Signal_context_capability sig,
        Genode::Semaphore &sem) :
    Genode::Thread(env, label, 4096),
    _socket(sock),
    _closed(false),
    _sig_cap(sig),
    _sem(sem)
{}

void Http_Filter::Async_Read::entry()
{
    char dummy;
    while(!_closed){
        recv(_socket, &dummy, 0, MSG_PEEK);
        Genode::Signal_transmitter(_sig_cap).submit();
        _sem.down();
    }
}

void Http_Filter::Async_Read::close()
{
    _closed = true;
    _sem.up();
}
