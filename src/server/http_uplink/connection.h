
#include <base/thread.h>
#include <terminal_session/connection.h>
#include <timer_session/connection.h>

namespace Http_Filter
{
    class Connection;
    enum {
        BUFSIZE = 64
    };
};

class Http_Filter::Connection : public Genode::Thread
{
    private:

        Terminal::Connection _terminal;
        Genode::Signal_handler<Connection> _read_sigh;
        int _socket;

        void handle_response();
        void entry() override;

    public:

        Connection (Genode::Env &, int);
};
