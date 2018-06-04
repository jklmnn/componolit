
#include <server.h>

#include <util/string.h>

#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <netinet/in.h>

Http_Filter::Server::Server(Genode::Env &env, int &connection, Genode::String<32> &label, Genode::Signal_context_capability const &cap) :
    Genode::Thread(env, "uplink server", (BUFSIZE + 4096) * CONNECTION_COUNT + 1),
    _env(env),
    _label(label),
    _connection(connection),
    _connection_sigh(cap)
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
            char lbl[32] = {};

            snprintf(lbl, 31, "%u.%u.%u.%u:%d",
                    (unsigned)ntohl(client.sin_addr.s_addr) >> 24,
                    ((unsigned)ntohl(client.sin_addr.s_addr) >> 16) & 0xff,
                    ((unsigned)ntohl(client.sin_addr.s_addr) >> 8) & 0xff,
                    (unsigned)ntohl(client.sin_addr.s_addr) & 0xff,
                    ntohs(client.sin_port));
            _connection = conn;
            _label = Genode::String<32>(lbl);
            Genode::log("Connection from: ", _label);

            Genode::Signal_transmitter(_connection_sigh).submit();
        }else{
            Genode::error("Connection failed");
        }
    }
}
