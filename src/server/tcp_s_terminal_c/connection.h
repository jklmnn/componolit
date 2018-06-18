
#include <libc_wrapper.h>

#include <base/thread.h>

namespace Tcp
{
    class Connection;
    enum {
        CONNECTION_BUFFER = 1024
    };
};

class Tcp::Connection : public Genode::Thread
{
    private:
        int _socket;
        bool _closed;

        void lc_read();
        void lc_write(void *, Genode::size_t);

        void entry() override;

    public:
        Connection(Genode::Env &, int, char const *);
        bool closed() const;
};
