
#include <base/component.h>
#include <base/heap.h>
#include <root/component.h>
#include <util/arg_string.h>

#include <timer_session/connection.h>

#include <nic/component.h>
#include <nic/packet_allocator.h>

namespace Nic_ping {
    class Session_component;
    class Root;
    struct Main;
};

class Nic_ping::Session_component : public Nic::Session_component
{
    private:
        enum {
            PACKET_SIZE = 64
        };

        Timer::Connection _timer;

    public:

        Session_component(
                Genode::size_t tx_buf_size,
                Genode::size_t rx_buf_size,
                Genode::Allocator &rx_block_md_alloc,
                Genode::Env &env) :
            Nic::Session_component(tx_buf_size, rx_buf_size, rx_block_md_alloc, env),
            _timer(env)
        { }

        Nic::Mac_address mac_address() override
        {
            char mac[6] = {1,1,1,1,1,1};
            return Nic::Mac_address { mac };
        }

        bool link_state() override
        {
            return true;
        }

        void _handle_packet_stream() override;
};

void Nic_ping::Session_component::_handle_packet_stream()
{

    for (;;) {
        while (_rx.source()->ack_avail())
            _rx.source()->release_packet(_rx.source()->get_acked_packet());

        if(_tx.sink()->packet_avail()){
            Nic::Packet_descriptor const packet = _tx.sink()->get_packet();
            Genode::log("received packet of size ", packet.size());
            _tx.sink()->acknowledge_packet(packet);
        }

        _timer.msleep(1000);
        
        /* send a test packet */
        if(_rx.source()->ready_to_submit()){
            Nic::Packet_descriptor packet;

            packet = _rx.source()->alloc_packet(PACKET_SIZE);

            char *content = _rx.source()->packet_content(packet);
            for(unsigned i = 0; i < PACKET_SIZE; ++i)
                content[i] = (char)i;

            _rx.source()->submit_packet(packet);

            Genode::log("sent packet");
        }
    }
}

class Nic_ping::Root : public Genode::Root_component<Session_component>
{
	private:

            Genode::Env  &_env;

	protected:

		Session_component *_create_session(char const *args)
		{
                    Genode::size_t ram_quota   = Genode::Arg_string::find_arg(args, "ram_quota"  ).ulong_value(0);
                    Genode::size_t tx_buf_size = Genode::Arg_string::find_arg(args, "tx_buf_size").ulong_value(0);
                    Genode::size_t rx_buf_size = Genode::Arg_string::find_arg(args, "rx_buf_size").ulong_value(0);

			/* deplete ram quota by the memory needed for the session structure */
                    Genode::size_t session_size = Genode::max(4096UL, (Genode::size_t)sizeof(Session_component));
			if (ram_quota < session_size)
				throw Genode::Insufficient_ram_quota();

			/*
			 * Check if donated ram quota suffices for both communication
			 * buffers and check for overflow
			 */
			if (tx_buf_size + rx_buf_size < tx_buf_size ||
			    tx_buf_size + rx_buf_size > ram_quota - session_size) {
                            Genode::error("insufficient 'ram_quota', got ", ram_quota, ", "
				      "need ", tx_buf_size + rx_buf_size + session_size);
				throw Genode::Insufficient_ram_quota();
			}

			return new (md_alloc()) Session_component(tx_buf_size, rx_buf_size,
			                                          *md_alloc(), _env);
		}

	public:

		Root(Genode::Env       &env,
		     Genode::Allocator &md_alloc)
		:
			Root_component<Session_component>(&env.ep().rpc_ep(), &md_alloc),
			_env(env)
		{ }
};

struct Nic_ping::Main
{
    Genode::Env &_env;

    Genode::Heap _heap {
        _env.ram(),
        _env.rm()
    };

    Nic_ping::Root _root {
        _env,
        _heap
    };
    
    Main(Genode::Env &env) : _env(env)
    {
        _env.parent().announce(_env.ep().manage(_root));
    }
};

void Component::construct(Genode::Env &env)
{
    static Nic_ping::Main main(env);
}
