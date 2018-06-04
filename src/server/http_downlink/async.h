
#include <base/thread.h>
#include <base/signal.h>

namespace Http_Filter
{
    class Async_Read;
};

class Http_Filter::Async_Read : public Genode::Thread
{
    private:

        int _socket;
        bool _closed;
        Genode::Signal_context_capability _sig_cap;
        Genode::Semaphore &_sem;

        void entry() override;

    public:
        Async_Read(Genode::Env &env, int sock, const char *label, Genode::Signal_context_capability sig,
                Genode::Semaphore &sem);
        void close();

};

