// Genode includes
#include <base/attached_rom_dataspace.h>
#include <base/component.h>
#include <base/heap.h>
#include <base/log.h>
#include <base/thread.h>
#include <nic/root.h>

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

namespace Nic_raw {
    class Main;
	using namespace Genode;
}

class Raw_ethernet_session_component : public Nic::Session_component
{
    private:

		struct Rx_signal_thread : Genode::Thread
		{
			int fd;
			Genode::Signal_context_capability sigh;

			Rx_signal_thread(Genode::Env &env, int fd, Genode::Signal_context_capability sigh)
			: Genode::Thread(env, "rx_signal", 0x1000), fd(fd), sigh(sigh) { }

			void entry()
			{
                for(;;)
                {
					int rv;
					fd_set read_fds;

					FD_ZERO (&read_fds);
					FD_SET (fd, &read_fds);
					do
                    {
                        rv = select (fd + 1, &read_fds, NULL, NULL, NULL);
                    } while (rv < 0);

					Genode::Signal_transmitter(sigh).submit();
                };
            }
        };

		bool _send()
		{
			using namespace Genode;

			if (!_tx.sink()->ready_to_ack())
            {
				return false;
            }

			if (!_tx.sink()->packet_avail())
            {
				return false;
            }

			Packet_descriptor packet = _tx.sink()->get_packet();
			if (!packet.size())
            {
				warning("invalid tx packet");
				return (true);
			}

			int ret;

			do {
				ret = write(_fd, _tx.sink()->packet_content(packet), packet.size());
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

		bool _receive()
		{
			unsigned const max_size = Nic::Packet_allocator::DEFAULT_PACKET_SIZE;

			if (!_rx.source()->ready_to_submit())
				return false;

			Nic::Packet_descriptor p;
			try {
				p = _rx.source()->alloc_packet(max_size);
			} catch (Session::Rx::Source::Packet_alloc_failed) { return false; }

			int size = read (_fd, _rx.source()->packet_content(p), max_size);
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
		                               Genode::Env        &env)
		:
			Session_component(tx_buf_size, rx_buf_size, rx_block_md_alloc, env),
			_config_rom(env, "config"),
			_fd(_open_socket()),
            _rx_thread(env, _fd, _packet_stream_dispatcher)
		{
			_rx_thread.start();
        }

	    bool link_state() override
        {
            return true;
        }

	    Nic::Mac_address mac_address() override
        {
            return _mac_addr;
        }

		Genode::Attached_rom_dataspace _config_rom;
		Nic::Mac_address _mac_addr;
		int              _fd;
		Rx_signal_thread _rx_thread;

		int _open_socket()
		{
            int fd;
            int rv = -1;
            int sockopt;
            struct sockaddr_ll bindaddr;
            struct ifreq if_idx;

            // Create socket (note: need root or CAP_NET_RAW)
            fd = socket (AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
            if (fd < 0)
            {
			    Genode::error("socket: ", Genode::Cstring(strerror(errno)));
				throw Genode::Exception();
            }

			// Make socket non-blocking
			rv = fcntl(fd, F_SETFL, O_NONBLOCK);
            if (rv < 0)
            {
			    Genode::error("fcntl(O_NONBLOCK): ", Genode::Cstring(strerror(errno)));
				throw Genode::Exception();
			}

            // Make socket reusable
            sockopt = 1;
            rv = setsockopt (fd, SOL_SOCKET, SO_REUSEADDR, &sockopt, sizeof (sockopt));
            if (rv < 0)
            {
			    Genode::error("setsockopt(SO_REUSEADDR): ", Genode::Cstring(strerror(errno)));
				throw Genode::Exception();
            }

            // Get interface index
            bzero (&if_idx, sizeof (if_idx));
			_config_rom.xml().attribute("interface").value(if_idx.ifr_name, sizeof(if_idx.ifr_name));
			Genode::log("Using device \"", Genode::Cstring(if_idx.ifr_name), "\"");

            rv = ioctl (fd, SIOCGIFINDEX, &if_idx);
            if (rv < 0)
            {
			    Genode::error("ioctl(SIOCGIFINDEX): ", Genode::Cstring(strerror(errno)));
				throw Genode::Exception();
            }

            // Bind socket to interface
            rv = setsockopt (fd, SOL_SOCKET, SO_BINDTODEVICE, (void *)&if_idx, sizeof(if_idx));
            if (rv < 0)
            {
			    Genode::error("setsockopt(SO_BINDTODEVICE): ", Genode::Cstring(strerror(errno)));
				throw Genode::Exception();
            }

            // Bind to interfaces for sending
            bzero (&bindaddr, sizeof(bindaddr));
            bindaddr.sll_family   = AF_PACKET;
            bindaddr.sll_protocol = htons(ETH_P_ALL);
            bindaddr.sll_ifindex  = if_idx.ifr_ifindex;

            rv = bind (fd, (struct sockaddr *)&bindaddr, sizeof (bindaddr));
            if (rv < 0)
            {
			    Genode::error("bind: ", Genode::Cstring(strerror(errno)));
				throw Genode::Exception();
            }

            return fd;
        }
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
