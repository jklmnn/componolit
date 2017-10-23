
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

        friend class Session;
        class Session : public Nic::Session_component
        {
            public:
                Session (
                        Genode::size_t tx_buf_size,
                        Genode::size_t rx_buf_size,
                        Genode::Allocator &rx_block_md_alloc,
                        Genode::Env &env);
            
                Nic::Mac_address mac_address() override;
                bool link_state() override;
                void _handle_packet_stream() override;
        };

        friend class Client;
        class Client
        {
            private:
                Genode::Env &_env;

                Genode::Heap _heap;

                Genode::Allocator_avl _tx_block_alloc;

                enum { BUF_SIZE = Nic::Packet_allocator::DEFAULT_PACKET_SIZE * 128 };

                Nic::Connection _nic;

                void _handle_nic();

                Genode::Signal_handler<Client> _nic_handler {
                    _env.ep(),
                    *this,
                    &Client::_handle_nic
                };

            public:
                Client(Genode::Env &);
        };

        friend class Root;
        class Root : public Genode::Root_component<Session>
        {
            private:
                Genode::Env &_env;
            
            protected:
                Session *_create_session(char const *);

            public:
                Root(Genode::Env &, Genode::Allocator &);

        };
       
        Genode::Heap _heap;

        Root _root;

        Client _client;

        virtual void up_filter() = 0;
        virtual void down_filter() = 0;

    public:
        Filter(Genode::Env &);
};

#endif //_NIC_FILTER_H_
