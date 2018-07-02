
#include <connection.h>

#include <base/thread.h>
#include <util/reconstructible.h>

namespace Tcp
{
    class Server;
    enum {
        CONNECTION_COUNT = 3
    };
    class Libc_Error : public Genode::Exception {};
};

class Tcp::Server : public Genode::Thread
{
    private:
        Genode::Env &_env;
        Genode::Constructible<Connection> _connection_pool[CONNECTION_COUNT];
        short _port;
        int _socket;

        bool update_connection(int, char *);

        void lc_setup();
        void lc_accept();

        void entry() override;
    public:
        Server(Genode::Env &, short);
};
