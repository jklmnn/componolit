
#include <base/log.h>
#include <base/component.h>
#include <filter.h>

#include <timer_session/connection.h>

namespace Nic_filter_test {
    class Filter;
    struct Main;
}

class Nic_filter_test::Filter : Nic_filter::Filter
{
    private:

        Timer::Connection _timer;

        void from_client(const char *buffer, Genode::size_t size, Genode::off_t offset,
                Nic_filter::Filter::Session *session) override
        {
            _timer.usleep(10); //XXX: only needed to fix the roundtrip test of test-nic_loopback
            char *sbuf = 0;
            Nic::Packet_descriptor packet = session->get_server_buffer(&sbuf, size, offset);
            Genode::memcpy(sbuf, buffer, size);
            session->to_server(packet);
        }

        void from_server(const char *buffer, Genode::size_t size, Genode::off_t offset,
                Nic_filter::Filter::Session *session) override
        {
            _timer.usleep(10); //XXX: only needed to fix the roundtrip test of test-nic_loopback
            char *cbuf = 0;
            Nic::Packet_descriptor packet = session->get_client_buffer(&cbuf, size, offset);
            Genode::memcpy(cbuf, buffer, size);
            session->to_client(packet);
        }

    public:
        Filter(Genode::Env &env) : Nic_filter::Filter(env), _timer(env)
    { }

    __attribute__((noinline)) static void hello_world(int num)
    {
        Genode::log(num);
    }
};

extern "C" void nic_filter__test(int);

struct Nic_filter_test::Main
{

    Filter _filter;

    Main(Genode::Env &env) : _filter(env)
    {
        Nic_filter_test::Filter::hello_world(1);
        nic_filter__test(2);
        Nic_filter_test::Filter::hello_world(3);
    }
};

void Component::construct(Genode::Env &env)
{
    static Nic_filter_test::Main main(env);
}
