
#include <libc/component.h>
#include <root/component.h>
#include <base/heap.h>
#include <timer_session/connection.h>

#include <component.h>

namespace Http_Filter
{
    struct Main;
};

struct Http_Filter::Main
{
    Genode::Env &_env;
    Timer::Connection _timer;

    Genode::Sliced_heap _heap { _env.ram(), _env.rm() };

    Root _root { _env, _env.ep(), _heap, _env.ram(), _env.rm() };

    Main(Genode::Env &env) : _env(env), _timer(env)
    {
        Genode::log("http_downlink");
        _timer.msleep(6000);
        env.parent().announce(env.ep().manage(_root));
    }
};

void Libc::Component::construct(Libc::Env &env)
{
    static Http_Filter::Main main(env);
}
