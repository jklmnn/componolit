
#include <libc/component.h>
#include <timer_session/connection.h>
#include <base/signal.h>

#include <server.h>

namespace Http_Filter
{
    struct Main;
}

struct Http_Filter::Main
{
    Genode::Env &_env;
    Timer::Connection _timer;
    Server _server;

    Main(Genode::Env &env) :
        _env(env),
        _timer(env),
        _server(env)
    {
        Genode::log("http_uplink");
        _timer.msleep(6000);
        _server.start();
        Genode::log("uplink ready");
    }
};

void Libc::Component::construct(Libc::Env &env)
{
    static Http_Filter::Main main(env);
}
