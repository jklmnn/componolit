
#include <base/thread.h>
#include <util/reconstructible.h>

#include <connection.h>

namespace Http_Filter {
    class Server;
    enum {
        CONNECTION_COUNT = 2
    };
};

class Http_Filter::Server : public Genode::Thread
{
    private:

        Genode::Env &_env;
        Genode::String<32> &_label;
        int &_connection;
        void entry() override;
        Genode::Signal_context_capability _connection_sigh;

    public:

        Server(Genode::Env &, int &, Genode::String<32> &, Genode::Signal_context_capability const &);
};
