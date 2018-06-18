
#include <base/thread.h>
#include <util/reconstructible.h>

#include <connection.h>

namespace Http_Filter {
    class Server;
    enum {
        CONNECTION_COUNT = 1
    };
};

class Http_Filter::Server : public Genode::Thread
{
    private:

        Genode::Env &_env;
        Genode::Constructible<Connection> _connection_pool[CONNECTION_COUNT];
        Genode::Signal_handler<Server> _connection_sigh;
        void entry() override;
        void close_connection();
        void start_connection(int, Genode::String<32>);

    public:

        Server(Genode::Env &);
};
