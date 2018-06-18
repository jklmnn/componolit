
#include <libc/component.h>

#include <server.h>

namespace Tcp
{
    struct Main;
};

struct Tcp::Main
{
    Genode::Env &_env;
    Server _server;

    Main(Genode::Env &env)
        : _env(env), _server(env, 80)
    {
        Genode::log("tcp_terminal");
        _server.start();
    }
};

void Libc::Component::construct(Libc::Env &env)
{
    static Tcp::Main main(env);
}
