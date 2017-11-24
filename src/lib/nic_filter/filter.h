
#ifndef _FILTER_H_
#define _FILTER_H_

#include <base/log.h>

namespace Nic_filter {
    class Filter;
};

class Nic_filter::Filter
{
    public:
        Filter() { }
        
        void filter()
        {
            Genode::log(__func__);
        }
};

#endif //_FILTER_H_
