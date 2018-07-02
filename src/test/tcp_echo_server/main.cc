
#include <libc/component.h>
#include <timer_session/connection.h>

#include <server.h>

namespace Tcp
{
    struct Main;
};

struct Tcp::Main
{
    Genode::Env &_env;
    Server _server;
    Timer::Connection _timer;

    Main(Genode::Env &env)
        : _env(env), _server(env, 21), _timer(env)
    {
        Genode::log("tcp_echo_server");
        _timer.msleep(6000);
        _server.start();
    }
};

void Libc::Component::construct(Libc::Env &env)
{
    static Tcp::Main main(env);
}
