
#ifndef _FILTER_H_
#define _FILTER_H_

#include <base/log.h>
#include <base/registry.h>
#include <util/string.h>

namespace Nic_filter {
    class Filter;
    class Interface;
    typedef enum {
        UNKNOWN = 0,
        UP      = 1,
        DOWN    = 2
    } direction_t;
};

class Nic_filter::Interface
{
    private:
        
        Genode::Registry<Nic_filter::Interface>::Element _elem;
        void *_iface = 0;
        void (*_submit)(void *, Genode::size_t, void *) = 0;
        int _id = 0;

    public:

        Interface(Genode::Registry<Nic_filter::Interface> &reg, void *iface,
                void (*submit)(void *, Genode::size_t, void *), int id) :
            _elem(reg, *this), _iface(iface), _submit(submit), _id(id)
        { }

        void submit(void *buffer, Genode::size_t size, int iface)
        {
            if(iface == _id){
                if(_iface && _submit){
                    _submit(buffer, size, _iface);
                }else{
                    Genode::warning("Filter interface not set. Dropping packet.");
                }
            }
        }
};

class Nic_filter::Filter
{
    private:

        enum {
            BUFFER_SIZE = 8192UL
        };

        Genode::Registry<Nic_filter::Interface> _reg;

    protected:

        void send(void *buffer, Genode::size_t size, int id)
        {
            _reg.for_each([&] (Nic_filter::Interface &iface){
                        iface.submit(buffer, size, id);
                    });
        }

    public:
        Filter() { }

        Genode::Registry<Nic_filter::Interface> &registry()
        {
            return _reg;
        }
        
        virtual void filter(const void *, const Genode::size_t, direction_t, int) = 0;
};

#endif //_FILTER_H_
