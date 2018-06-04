
#include <base/thread.h>
#include <terminal_session/connection.h>
#include <timer_session/connection.h>

namespace Http_Filter
{
    class Connection;
    class Connection_loop;
    struct Connection_info;
    enum {
        BUFSIZE = 1024
    };
};

class Http_Filter::Connection_loop : public Genode::Thread
{
    private:
        int _socket;
        bool &_closed;
        Terminal::Connection &_terminal;
        Genode::Signal_context_capability _csigh;

        void entry() override;

    public:
        Connection_loop (Genode::Env &, int, Genode::String<32>, Terminal::Connection &, bool &,
                Genode::Signal_context_capability);
};

class Http_Filter::Connection
{
    private:

        Genode::Env &_env;
        Terminal::Connection _terminal;
        Genode::Signal_handler<Connection> _read_sigh;
        Genode::Signal_handler<Connection> _close_sigh;
        Genode::Signal_context_capability _close_signal;
        int _socket;
        bool _closed;
        Connection_loop _loop;

        void handle_response();
        void handle_close();

    public:

        Connection (Genode::Env &, int, Genode::String<32>, Genode::Signal_context_capability);
        void start();
        bool closed() const;
        void join();
};
