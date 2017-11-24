
#ifndef _FILTER_H_
#define _FILTER_H_

#include <base/log.h>
#include <util/string.h>

namespace Nic_filter {
    class Filter;
};

class Nic_filter::Filter
{
    private:

        enum {
            BUFFER_SIZE = 8192UL
        };

    public:
        Filter() { }
        
        Genode::size_t filter(void *buffer, const void *data, const Genode::size_t size)
        {
            Genode::log(__func__);
            if(size > buffer_size())
                Genode::warning("insufficient buffer size ", buffer_size(), " < ", size);
            Genode::memcpy(buffer, data, Genode::min(size, buffer_size()));
            return size;
        }

        Genode::size_t buffer_size() const
        {
            return BUFFER_SIZE;
        }
};

#endif //_FILTER_H_
