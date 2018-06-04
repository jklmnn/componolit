
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
        Terminal::Connection &_terminal;

        void entry() override;

    public:
        Connection_loop (Genode::Env &, int, Genode::String<32>, Terminal::Connection &);
};

class Http_Filter::Connection
{
    private:

        Genode::Env &_env;
        Terminal::Connection _terminal;
        Genode::Signal_handler<Connection> _read_sigh;
        int _socket;
        Connection_loop _loop;

        void handle_response();

    public:

        Connection (Genode::Env &, int, Genode::String<32>);
        void start();
};
