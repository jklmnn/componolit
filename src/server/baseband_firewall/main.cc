
#include <base/log.h>
#include <base/component.h>
#include <nic_filter.h>

#include <timer_session/connection.h>

#include <buffer_dump.h>

#include <fw.h>

namespace Baseband {
    class Firewall;
    struct Main;
    enum {
        BUFSIZE = 4096
    };
}

class Baseband::Firewall : public Nic_filter::Filter
{

    private:

        Genode::uint8_t buffer[2 * BUFSIZE];

    public:
        
        Firewall() : Nic_filter::Filter() { }
        
        static void submit(void *self, unsigned size, int iface)
        {
            ((Firewall *)self)->send(((Firewall *)self)->buffer, size, iface);
        }

        void filter(const void *data, const Genode::size_t size, Nic_filter::direction_t dir, int iface) override
        {
            int select_send = 0;
            //Genode::log(__func__, Buffer_dump<Genode::uint32_t, 4>((Genode::uint32_t *)data, Genode::min(16, size / sizeof(Genode::uint32_t))));
            baseband_fw__filter_hook(buffer, data, sizeof(buffer), size, (int)dir, this, iface);
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

extern "C" {
    
    void submit(void *fw, unsigned size, int iface)
    {
        Baseband::Firewall::submit(fw, size, iface);
    }

};

