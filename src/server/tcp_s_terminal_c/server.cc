
#include <libc_wrapper.h>
#include <server.h>

#include <util/string.h>

#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <netinet/in.h>

Tcp::Server::Server(Genode::Env &env, short port) :
    Genode::Thread(env, "tcp server", CONNECTION_COUNT * (CONNECTION_BUFFER + 4096) + 4096),
    _env(env),
    _port(port),
    _socket(-1)
{
    Genode::log(__func__);
}

void Tcp::Server::entry()
{
    LIBC(setup);
    LIBC(accept);
}

bool Tcp::Server::update_connection(int sock, char *label)
{
    bool started = false;
    int cleaned = 0;
    for(unsigned i = 0; i < CONNECTION_COUNT; i++){
        if(_connection_pool[i].constructed() && _connection_pool[i] -> closed()){
            _connection_pool[i].destruct();
            cleaned++;
        }
        if(!started && !_connection_pool[i].constructed()){
            _connection_pool[i].construct(_env, sock, label);
            _connection_pool[i]->start();
            started = true;
        }
    }
    Genode::log("cleaned ", cleaned, " connections");

    return started;
}

void Tcp::Server::lc_setup()
{
    struct sockaddr_in serv;
    int result;

    Genode::memset(&serv, 0, sizeof(struct sockaddr_in));

    serv.sin_family = AF_INET;
    serv.sin_addr.s_addr = INADDR_ANY;
    serv.sin_port = htons(_port);

    _socket = socket(AF_INET, SOCK_STREAM, 0);

    if(_socket < 0){
        Genode::error("Failed to open socket: ", _socket);
    }

    result = bind(_socket, (struct sockaddr *)&serv, sizeof(serv));
    if(result < 0){
        Genode::error("Failed to bind: ", result);
    }

    listen(_socket, CONNECTION_COUNT);
}

void Tcp::Server::lc_accept()
{
    socklen_t clilen;
    struct sockaddr_in client;
    int connection;
    char label[32] = {};

    while(true){
        Genode::memset(&client, 0, sizeof(struct sockaddr_in));
        clilen = sizeof(client);
        connection = accept(_socket, (struct sockaddr *)&client, &clilen);

        if(connection > 0){
            snprintf(label, 31, "%u.%u.%u.%u:%d",
                    (unsigned)ntohl(client.sin_addr.s_addr) >> 24,
                    ((unsigned)ntohl(client.sin_addr.s_addr) >> 16) & 0xff,
                    ((unsigned)ntohl(client.sin_addr.s_addr) >> 8) & 0xff,
                    (unsigned)ntohl(client.sin_addr.s_addr) & 0xff,
                    ntohs(client.sin_port));
            Genode::log("Connection from ", Genode::Cstring(label));

            if(!update_connection(connection, label)){
                Genode::error("Failed to create new connection.");
                close(connection);
            }
        }else{
            Genode::error("accept failed ", connection);
        }
    }
}
