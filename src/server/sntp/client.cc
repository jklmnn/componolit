
#include <base/log.h>
#include <util/string.h>

#include <client.h>
#include <sntp.h>

/* socket */

Sntp::Client::Client(const char *host, long timeout) :
    _addr(0), _s(0), _timeout(timeout)
{
    Genode::log("sntp host ", Genode::Cstring(host), " timeout ", timeout, "us");
    _s = sntp__c_connect(host, Genode::strlen(host), &_addr);
    if(_s < 0){
        throw Sntp::Connection_failed();
    }
}


Genode::uint64_t Sntp::Client::timestamp()
{
    int retries = 5;
    Genode::uint64_t ts;
    while(ts = (Genode::uint64_t)sntp__c_get_time(_s, _addr, _timeout),
            !ts && retries--){
        Genode::warning("sntp timed out, retrying ", retries, " times...");
    }
    if(!ts){
        throw Sntp::Timeout();
    }

    return ts;
}
