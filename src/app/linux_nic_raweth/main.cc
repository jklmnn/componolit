// Genode includes
#include <base/component.h>
#include <base/heap.h>
#include <base/log.h>
#include <base/thread.h>
#include <base/allocator_avl.h>
#include <nic/packet_allocator.h>
#include <nic_session/connection.h>

// Linux includes
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <net/if.h>
#include <linux/if_packet.h>
#include <netinet/ether.h>
#include <sys/ioctl.h>
#include <arpa/inet.h>

// Local includes
#include <ethernet.h>

namespace Nic_raw {
    class Main;
    class Forward_sock_base;
    class Forward_sock_rx;
    class Forward_sock_tx;
	using namespace Genode;
}

enum
{
    PACKET_SIZE = 1500,
    BUF_SIZE = Nic::Session::QUEUE_SIZE * PACKET_SIZE
};

static char tx_buffer[PACKET_SIZE];

class Nic_raw::Forward_sock_base : public Genode::Thread
{
    protected:
        Nic_raw::Ethernet &_eth;
        Nic::Connection &_nic;

    public:
        Forward_sock_base(Genode::Env &env, Nic::Connection &nic, Nic_raw::Ethernet &eth, const char *name)
        :
            Genode::Thread(env, name, 0x1000),
            _eth(eth),
            _nic(nic)
        { }
};

class Nic_raw::Forward_sock_tx : public Forward_sock_base
{
    private:
        void entry() override
        {
            for(;;)
            {
                Genode::Signal sig = _sig_rec.wait_for_signal();
                int num = sig.num();

                Genode::Signal_dispatcher_base *dispatcher;
                dispatcher = dynamic_cast<Genode::Signal_dispatcher_base *>(sig.context());
                dispatcher->dispatch(num);
            };
        }

        void
        _handle_rx_packet_avail(unsigned)
        {
            while (_nic.rx()->packet_avail() && _nic.rx()->ready_to_ack())
            {
                Nic::Packet_descriptor rx_packet = _nic.rx()->get_packet();
                char *rx_buffer = _nic.rx()->packet_content(rx_packet);

                ssize_t bytes_written = _eth._write(rx_buffer, rx_packet.size());
                if (bytes_written < 0)
                {
                    warning("Error writing packet: ", Genode::Cstring(strerror(errno)));
                }
                _nic.rx()->acknowledge_packet(rx_packet);
            }
        }

        void
        _handle_rx_ready_to_ack(unsigned)
        {
            _handle_rx_packet_avail(0);
        }

        void
        _handle_link_state(unsigned)
        {
            log("Link state changed");
        }

        Genode::Signal_receiver _sig_rec;
        Genode::Signal_dispatcher<Forward_sock_tx> _rx_packet_avail_dispatcher;
        Genode::Signal_dispatcher<Forward_sock_tx> _rx_ready_to_ack_dispatcher;
        Genode::Signal_dispatcher<Forward_sock_tx> _link_state_dispatcher;

    public:

        Forward_sock_tx(Genode::Env &env, Nic::Connection &nic, Nic_raw::Ethernet &eth)
        :
            Forward_sock_base(env, nic, eth, "forward_tx"),
            _rx_packet_avail_dispatcher(_sig_rec, *this, &Forward_sock_tx::_handle_rx_packet_avail),
            _rx_ready_to_ack_dispatcher(_sig_rec, *this, &Forward_sock_tx::_handle_rx_ready_to_ack),
            _link_state_dispatcher(_sig_rec, *this, &Forward_sock_tx::_handle_link_state)
        {
            _nic.link_state_sigh(_link_state_dispatcher);
            _nic.rx_channel()->sigh_packet_avail(_rx_packet_avail_dispatcher);
            _nic.rx_channel()->sigh_ready_to_ack(_rx_ready_to_ack_dispatcher);
        };
};

class Nic_raw::Forward_sock_rx : public Nic_raw::Forward_sock_base
{
    private:
        void entry() override
        {
            for(;;)
            {
                _eth._wait_for_packet();

                Genode::memset(tx_buffer, 0, PACKET_SIZE);

                ssize_t bytes_read = _eth._read(tx_buffer, PACKET_SIZE);

                if (bytes_read < 0)
                {
                    warning("Error reading packet: ", Genode::Cstring(strerror(errno)));
                    continue;
                }
                
                Nic::Packet_descriptor tx_packet = _nic.tx()->alloc_packet(bytes_read);
                Genode::memcpy(_nic.tx()->packet_content(tx_packet), tx_buffer, bytes_read);

                _nic.tx()->submit_packet(tx_packet);
                while (_nic.tx()->ack_avail())
                {
                    Nic::Packet_descriptor acked_packet = _nic.tx()->get_acked_packet();
                    _nic.tx()->release_packet(acked_packet);
                }
            };
        }

    public:

        Forward_sock_rx(Genode::Env &env, Nic::Connection &nic, Nic_raw::Ethernet &eth)
        :
            Forward_sock_base(env, nic, eth, "forward_rx")
        { };
};

struct Nic_raw::Main
{
	Env  &_env;
	Heap _heap { _env.ram(), _env.rm() };
    Allocator_avl _tx_block_allocator { &_heap };
    Nic_raw::Ethernet _eth { _env };
    Nic::Connection _nic { _env, &_tx_block_allocator, BUF_SIZE, BUF_SIZE };

    Forward_sock_rx _forward_rx { _env, _nic, _eth };
    Forward_sock_tx _forward_tx { _env, _nic, _eth };

    Main(Genode::Env &env) : _env(env)
    {
        log("Started");
        _forward_rx.start();
        _forward_tx.start();
    }
};

void Component::construct(Genode::Env &env) { static Nic_raw::Main main(env); };
