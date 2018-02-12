
#include <base/log.h>
#include <base/component.h>
#include <nic_filter.h>

#include <timer_session/connection.h>

#include <ada_filter.h>

namespace Nic_filter_test {
    class Filter;
    struct Main;
}

class Nic_filter_test::Filter : public Nic_filter::Filter
{
    public:
        
        Filter() : Nic_filter::Filter() { }

        void filter(const void *data, const Genode::size_t size, Nic_filter::direction_t dir, int iface) override
        {
            const bool known = dir != Nic_filter::UNKNOWN;
            const bool up = dir == Nic_filter::UP;
            Genode::uint8_t buffer[size];
            //Genode::log((known && up) ? "<- " : "-> ", size, " bytes");
            nic_filter__filter(buffer, data, size, size);
            send(buffer, size, iface);
        }

};


struct Nic_filter_test::Main
{

    Filter _filter;

    Nic_filter::Nic_filter _nf;

    Main(Genode::Env &env) : _nf(env, _filter)
    {
        Genode::log("-- nic filter --");
    }
};

void Component::construct(Genode::Env &env)
{
    /* XXX execute constructors of global statics */
    env.exec_static_constructors();
    static Nic_filter_test::Main main(env);
}
