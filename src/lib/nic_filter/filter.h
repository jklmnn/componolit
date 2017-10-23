
#ifndef _NIC_FILTER_H_
#define _NIC_FILTER_H_

#include <base/log.h>
#include <base/heap.h>
#include <root/component.h>
#include <util/arg_string.h>

#include <nic/component.h>
#include <nic/packet_allocator.h>
#include <nic_session/connection.h>


namespace Nic_filter {
    class Filter;
};

class Nic_filter::Filter
{
    private:

        Genode::size_t _rx_buf = 0;
        Genode::size_t _tx_buf = 0;

        friend class Session;
        class Session : public Nic::Session_component
        {
            private:
                Genode::Env &_env;

                Genode::Heap _heap;

                Genode::Allocator_avl _tx_block_alloc;

                Nic::Connection _nic;

                void _handle_nic();

                Genode::Signal_handler<Session> _nic_handler;

                Filter *_filter;

            public:
                Session (
                        Genode::size_t,
                        Genode::size_t,
                        Genode::Allocator &,
                        Genode::Env &,
                        Filter*);
            
                Nic::Mac_address mac_address() override;
                bool link_state() override;
                void _handle_packet_stream() override;
        };

        friend class Root;
        class Root : public Genode::Root_component<Session>
        {
            private:
                Genode::Env &_env;
                Filter *_filter;
            
            protected:
                Session *_create_session(char const *);

            public:
                Root(Genode::Env &, Genode::Allocator &, Filter*);

        };
       
        Genode::Heap _heap;

        Root _root;

        void update_buf_size(Genode::size_t, Genode::size_t);

        virtual void up_filter(char *, Genode::size_t) = 0;
        virtual void down_filter(char*, Genode::size_t) = 0;

    public:
        Filter(Genode::Env &);
};

#endif //_NIC_FILTER_H_
