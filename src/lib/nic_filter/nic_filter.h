
#ifndef _NIC_FILTER_H_
#define _NIC_FILTER_H_

#include <base/log.h>
#include <base/heap.h>
#include <base/attached_rom_dataspace.h>
#include <timer_session/connection.h>

#include <component.h>
#include <interface.h>
#include <filter.h>

namespace Nic_filter {
    struct Nic_filter;
};

struct Nic_filter::Nic_filter
{
    private:    
    
        Genode::Attached_rom_dataspace _config;
        Timer::Connection _timer;
        Genode::Duration _curr_time { Genode::Microseconds(0UL) };
        Genode::Heap _heap;
        Net::Root _root;

    public:

        Nic_filter(Genode::Env &env, Filter &filter):
            _config(env, "config"),
            _timer(env),
            _heap(&env.ram(), &env.rm()),
            _root(env, _heap, _config.xml(), _timer, _curr_time, filter)
        {
            env.parent().announce(env.ep().manage(_root));
        }

            
};

#endif //_NIC_FILTER_H_
