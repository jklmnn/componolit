// Genode includes
#include <base/component.h>
#include <base/heap.h>
#include <base/log.h>
#include <base/thread.h>
#include <nic/root.h>
#include <os/packet_stream.h>

// FIXME: Linux include
#include <errno.h>

// Local includes
#include <ethernet.h>

namespace Nic_raw {
    class Main;
    using namespace Genode;
}

class Raw_ethernet_session_component;

class Raw_ethernet_session_component : public Nic::Session_component,
                                       public Nic_raw::Ethernet
{
    private:

        struct Rx_signal_thread : Genode::Thread
        {
            Genode::Signal_context_capability _sigh;
            Raw_ethernet_session_component *_eth;

            Rx_signal_thread(Genode::Env &env, Raw_ethernet_session_component *eth, Genode::Signal_context_capability sigh)
            : Genode::Thread(env, "rx_signal", 0x1000), _sigh(sigh), _eth(eth) { }

            void entry()
            {
                for(;;)
                {
                    _eth->_wait_for_packet();
                    Genode::Signal_transmitter(_sigh).submit();
                };
            }
        };

    protected:

        void _handle_packet_stream() override
        {
            while (_rx.source()->ack_avail())
                _rx.source()->release_packet(_rx.source()->get_acked_packet());

            while (_send());
            while (_receive());
        }

    public:

        Raw_ethernet_session_component(size_t const tx_buf_size,
                                       size_t const rx_buf_size,
                                       Genode::Allocator &rx_block_md_alloc,
                                       Genode::Env       &env)
        :
            Session_component(tx_buf_size, rx_buf_size, rx_block_md_alloc, env),
            Ethernet(env),
            _rx_thread(env, this, _packet_stream_dispatcher)
        {
            _rx_thread.start();
        }

        bool
        _send()
        {
            if (!_tx.sink()->ready_to_ack())
            {
                return false;
            }

            if (!_tx.sink()->packet_avail())
            {
                return false;
            }

            Nic::Packet_descriptor packet = _tx.sink()->get_packet();
            if (!packet.size())
            {
                Genode::warning("invalid tx packet");
                return (true);
            }

            int ret;

            do {
                ret = _write(_tx.sink()->packet_content(packet), packet.size());
                /* drop packet if write would block */
                if (ret < 0 && errno == EAGAIN)
                {
                    continue;
                }

                if (ret < 0)
                {
                    Genode::error("write: errno=", errno);
                }

            } while (ret < 0);

            _tx.sink()->acknowledge_packet(packet);

            return true;
        }

        bool
        _receive()
        {
            unsigned const max_size = Nic::Packet_allocator::DEFAULT_PACKET_SIZE;

            if (!_rx.source()->ready_to_submit())
                return false;

            Nic::Packet_descriptor p;
            try {
                p = _rx.source()->alloc_packet(max_size);
            } catch (Session::Rx::Source::Packet_alloc_failed) { return false; }

            int size = _read (_rx.source()->packet_content(p), max_size);
            if (size <= 0)
            {
                _rx.source()->release_packet(p);
                return false;
            }

            /* adjust packet size */
            Nic::Packet_descriptor p_adjust(p.offset(), size);
            _rx.source()->submit_packet(p_adjust);

            return true;
        }

        bool link_state() override
        {
            return true;
        }

        Nic::Mac_address mac_address() override
        {
            return _mac_addr;
        }

        Nic::Mac_address _mac_addr;
        Rx_signal_thread _rx_thread;

};

struct Nic_raw::Main
{
    Env  &_env;
    Heap _heap { _env.ram(), _env.rm() };

    Nic::Root<Raw_ethernet_session_component> nic_root { _env, _heap };

    Main(Genode::Env &env) : _env(env)
    {
        _env.parent().announce(_env.ep().manage(nic_root));
    }
};

void Component::construct(Genode::Env &env) { static Nic_raw::Main main(env); };
