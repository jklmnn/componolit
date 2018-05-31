
#include <base/thread.h>
#include <terminal_session/connection.h>
#include <timer_session/connection.h>

namespace Http_Filter
{
    class Connection;
    struct Connection_info;
    enum {
        BUFSIZE = 1024
    };
};

class Http_Filter::Connection : public Genode::Thread
{
    private:

        Genode::Env &_env;
        Terminal::Connection _terminal;
        Genode::Signal_handler<Connection> _read_sigh;
        int _socket;

        void entry() override;

    public:

        void handle_response();
        Connection (Genode::Env &, int, Genode::String<32>);
};
