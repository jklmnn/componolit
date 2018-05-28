
#include <libc/component.h>
#include <timer_session/connection.h>

#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <netinet/in.h>

#include <connection.h>

namespace Http_Filter
{
    struct Main;
    enum {
        CONNECTION_COUNT = 10
    };
}

struct Http_Filter::Main
{
    Genode::Env &_env;
    Timer::Connection _timer;

    Genode::Constructible<Connection> Connection_Pool[CONNECTION_COUNT];

    void listen_and_dispatch()
    {
        struct sockaddr_in serv, client;
        socklen_t client_length;
        int sock = socket(AF_INET, SOCK_STREAM, 0);
        int conn;

        Genode::memset (&serv, 0, sizeof(struct sockaddr_in));

        serv.sin_family = AF_INET;
        serv.sin_addr.s_addr = INADDR_ANY;
        serv.sin_port = htons(80);

        if (bind(sock, (struct sockaddr *)&serv, sizeof(serv)) < 0){
            Genode::error("Failed to bind");
            return;
        }

        listen(sock, CONNECTION_COUNT);

        while (true){
            Genode::memset (&client, 0, sizeof(struct sockaddr_in));
            client_length = sizeof(client);
            conn = accept(sock, (struct sockaddr*)&client, &client_length);
            if (conn >= 0){
                bool pool_not_full = false;
                char lbl[32] = {};

                snprintf(lbl, 31, "%u.%u.%u.%u:%d",
                        (unsigned)ntohl(client.sin_addr.s_addr) >> 24,
                        ((unsigned)ntohl(client.sin_addr.s_addr) >> 16) & 0xff,
                        ((unsigned)ntohl(client.sin_addr.s_addr) >> 8) & 0xff,
                        (unsigned)ntohl(client.sin_addr.s_addr) & 0xff,
                        ntohs(client.sin_port));
                Genode::String<32> label = Genode::String<32>(lbl);
                Genode::log("Connection from: ", label);

                for(unsigned i = 0; i < sizeof(Connection_Pool) / sizeof(Connection); i++){
                    if (!Connection_Pool[i].constructed()){
                        pool_not_full = true;
                        Connection_Pool[i].construct(_env, conn, label);
                        Connection_Pool[i]->start();
                    }
                }
                if(!pool_not_full){
                    Genode::warning("Connection pool is full, closing connection");
                    close(conn);
                }
            }else{
                Genode::error("Connection failed");
            }
        }
    }

    Main(Genode::Env &env) : _env(env), _timer(env)
    {
        Genode::log("http_uplink");
        _timer.msleep(6000);
        Libc::with_libc([&](){
                listen_and_dispatch();
                });
    }
};

void Libc::Component::construct(Libc::Env &env)
{
    static Http_Filter::Main main(env);
}
