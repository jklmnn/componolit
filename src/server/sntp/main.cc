
#include <libc/component.h>
#include <base/component.h>
#include <base/log.h>
#include <base/heap.h>
#include <root/component.h>
#include <rtc_session/rtc_session.h>
#include <timer_session/connection.h>
#include <base/attached_rom_dataspace.h>
#include <util/xml_node.h>

#include <time.h>

#include <client.h>

namespace Sntp {
    struct Session_component;
    struct Root;
    struct Main;
};

struct Sntp::Session_component : public Genode::Rpc_object<Rtc::Session>
{
    Genode::Env &_env;

    Genode::Attached_rom_dataspace _config { _env, "config" };

    Sntp::Client _client {
        _config.xml().sub_node("sntp")
            .attribute_value("host", Genode::String<64>()).string(),
        _config.xml().sub_node("sntp")
            .attribute_value<long>("timeout", 0)
    };

    Session_component(Genode::Env &env) :
        _env(env)
    { }

    Rtc::Timestamp current_time()
    {
        time_t ts;
        struct tm *tm;
        Rtc::Timestamp time {};

        Libc::with_libc([&](){
                
                ts = _client.timestamp();
                tm = gmtime(&ts);
        
                time.second = tm->tm_sec;
                time.minute = tm->tm_min;
                time.hour = tm->tm_hour;
                time.day = tm->tm_mday;
                time.month = tm->tm_mon + 1;
                time.year = tm->tm_year + 1900;

                });

        return time;
    }
};

struct Sntp::Root : public Genode::Root_component<Session_component>
{
    private:

        Genode::Env &_env;

    protected:

        Session_component *_create_session(const char *)
        {
            return new (md_alloc()) Session_component(_env);
        }

    public:

        Root(Genode::Env &env, Genode::Allocator &md_alloc) :
            Genode::Root_component<Session_component>(&env.ep().rpc_ep(), &md_alloc),
            _env(env)
    { }
};

struct Sntp::Main
{
    Genode::Env &_env;

    Timer::Connection _timer;

    Genode::Sliced_heap _sheap { _env.ram(), _env.rm() };

    Root _root { _env, _sheap };

    Main(Genode::Env &env) : _env(env), _timer(env)
    {
        Genode::log("---sntp---");
        /* waiting for DHCP */
        _timer.msleep(6000);
        _env.parent().announce(_env.ep().manage(_root));
    }
};

void Libc::Component::construct(Libc::Env &env)
{
    static Sntp::Main main(env);
}
