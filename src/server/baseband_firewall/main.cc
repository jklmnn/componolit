
#include <base/log.h>
#include <base/component.h>
#include <nic_filter.h>

#include <timer_session/connection.h>

#include <buffer_dump.h>

#include <fw.h>

namespace Baseband {
    class Firewall;
    struct Main;
}

class Baseband::Firewall : public Nic_filter::Filter
{
    public:
        
        Firewall() : Nic_filter::Filter() { }

        Genode::size_t filter(void *buffer, const void *data, const Genode::size_t size, Nic_filter::direction_t dir) override
        {
            const Genode::size_t bufsize = buffer_size(size);
            Genode::log(__func__, Buffer_dump<Genode::uint32_t, 4>((Genode::uint32_t *)data, Genode::min(16, size / sizeof(Genode::uint32_t))));
            baseband_fw__filter_hook(buffer, data, bufsize, size, (int)dir);
            return bufsize;
        }

        Genode::size_t buffer_size(const Genode::size_t size) const override
        {
            return size;
        }

};


struct Baseband::Main
{

    Firewall _fw;

    Nic_filter::Nic_filter _nf;

    Main(Genode::Env &env) : _nf(env, _fw)
    {
        Genode::log("-- baseband firewall --");
    }
};

void Component::construct(Genode::Env &env)
{
    /* XXX execute constructors of global statics */
    env.exec_static_constructors();
    static Baseband::Main main(env);
}
