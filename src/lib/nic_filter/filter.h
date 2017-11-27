
#ifndef _FILTER_H_
#define _FILTER_H_

#include <base/log.h>
#include <util/string.h>

namespace Nic_filter {
    class Filter;
    typedef enum {
        UNKNOWN,
        UP,
        DOWN
    } direction_t;
};

class Nic_filter::Filter
{
    private:

        enum {
            BUFFER_SIZE = 8192UL
        };

    public:
        Filter() { }
        
        virtual Genode::size_t filter(void *, const void *, const Genode::size_t, direction_t) = 0;

        virtual Genode::size_t buffer_size(const Genode::size_t) const = 0;
};

#endif //_FILTER_H_
