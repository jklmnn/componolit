
#include <libc_wrapper.h>

#include <base/thread.h>
#include <terminal_session/connection.h>
#include <base/signal.h>

namespace Tcp
{
    class Connection;
    enum {
        CONNECTION_BUFFER = 4096
    };
};

class Tcp::Connection : public Genode::Thread
{
    private:
        Terminal::Connection _terminal;
        Genode::Signal_handler<Connection> _read_sigh;
        int _socket;
        bool _closed;

        void lc_read(void *, Genode::size_t, long *);
        void lc_write(void const *, Genode::size_t, long *);
        void lc_close();

        void handle_response();
        void entry() override;

    public:
        Connection(Genode::Env &, int, char const *);
        bool closed() const;
};
