
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
    Genode::Signal_handler<Main> _csigh;
    Server _server;
    Genode::Constructible<Connection> _connection_pool[CONNECTION_COUNT];
    Genode::String<32> _label;
    int _connection;

    void handle_connection()
    {
        bool pool_not_full = false;
        Genode::log(__func__);
        for(unsigned i = 0; i < sizeof(_connection_pool) / sizeof(Connection); i++){
            if (!_connection_pool[i].constructed()){
                pool_not_full = true;
                _connection_pool[i].construct(_env, _connection, _label);
                _connection_pool[i]->start();
            }
        }
        if(!pool_not_full){
            Genode::warning("Connection pool is full, closing connection");
        }
    }

    Main(Genode::Env &env) :
        _env(env),
        _timer(env),
        _csigh(env.ep(), *this, &Main::handle_connection),
        _server(env, _connection, _label, _csigh),
        _label(""),
        _connection(-1)
    {
        Genode::log("http_uplink");
        _timer.msleep(6000);
        Libc::with_libc([&](){
                _server.start();
                });
    }
};

void Libc::Component::construct(Libc::Env &env)
{
    static Http_Filter::Main main(env);
}
