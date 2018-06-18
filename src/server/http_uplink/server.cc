
#include <server.h>

#include <util/string.h>
#include <libc/component.h>

#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <netinet/in.h>

Http_Filter::Server::Server(Genode::Env &env) :
    Genode::Thread(env, "uplink server", (BUFSIZE + 4096) * CONNECTION_COUNT + 1),
    _env(env),
    _connection_sigh(env.ep(), *this, &Http_Filter::Server::close_connection)
{ }

void Http_Filter::Server::entry()
{
    struct sockaddr_in serv, client;
    socklen_t client_length;
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    int conn;

    Genode::memset (&serv, 0, sizeof(struct sockaddr_in));

    serv.sin_family = AF_INET;
    serv.sin_addr.s_addr = INADDR_ANY;
    serv.sin_port = htons(80);

    Libc::with_libc([&] () {
        if (bind(sock, (struct sockaddr *)&serv, sizeof(serv)) < 0){
            Genode::error("Failed to bind");
            return;
        }

        listen(sock, CONNECTION_COUNT);

        while (true){
            Genode::memset (&client, 0, sizeof(struct sockaddr_in));
            client_length = sizeof(client);
            Genode::log("accepting connection...");
            conn = accept(sock, (struct sockaddr*)&client, &client_length);
            if (conn >= 0){
                char lbl[32] = {};

                snprintf(lbl, 31, "%u.%u.%u.%u:%d",
                        (unsigned)ntohl(client.sin_addr.s_addr) >> 24,
                        ((unsigned)ntohl(client.sin_addr.s_addr) >> 16) & 0xff,
                        ((unsigned)ntohl(client.sin_addr.s_addr) >> 8) & 0xff,
                        (unsigned)ntohl(client.sin_addr.s_addr) & 0xff,
                        ntohs(client.sin_port));
                Genode::log("Connection from: ", Genode::Cstring(lbl));

                start_connection(conn, Genode::String<32>(lbl));
            }else{
                Genode::error("Connection failed");
            }
        }
    });
}

void Http_Filter::Server::close_connection()
{
    Genode::log(__func__);
    for(unsigned i = 0; i < sizeof(_connection_pool) / sizeof(Connection); i++){
        if(_connection_pool[i].constructed() && _connection_pool[i]->closed()){
            Genode::log("closing connection ", i);
            _connection_pool[i]->join();
            Genode::log("connection ", _connection_pool[i].constructed());
            _connection_pool[i].destruct();
            Genode::log("connection ", _connection_pool[i].constructed());
        }
    }
}

void Http_Filter::Server::start_connection(int socket, Genode::String<32> label)
{
    Genode::log(__func__);
    bool pool_not_full = false;
    for(unsigned i = 0; i < sizeof(_connection_pool) / sizeof(Connection); i++){
        Genode::log(i);
        if (!_connection_pool[i].constructed() || 1){
            pool_not_full = true;
            Genode::log("Constructing connection ", i);
            _connection_pool[i].construct(_env, socket, label, _connection_sigh);
            Genode::log("Connection constructed");
            _connection_pool[i]->start();
            Genode::log("Connection started");
            break;
        }
    }
    if(!pool_not_full){
        Genode::warning("Connection pool is full, closing connection");
    }
}
