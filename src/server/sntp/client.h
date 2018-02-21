
#include <base/fixed_stdint.h>

#include <netdb.h>

namespace Sntp {
    class Client;
    class Connection_failed : Genode::Exception {};
    class Timeout : Genode::Exception {};
};

class Sntp::Client
{
    private:

        struct addrinfo *_addr;
        int _s;
        long _timeout;

    public:
        Client(const char *, long);

        Genode::uint64_t timestamp();
};

