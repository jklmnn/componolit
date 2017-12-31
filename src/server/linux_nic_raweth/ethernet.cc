// Genode includes
#include <nic_session/nic_session.h>
#include <nic/packet_allocator.h>
#include <os/packet_stream.h>

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

Nic_raw::Ethernet::Ethernet(Env &env)
:
    _config_rom(env, "config"),
    _fd(_open_socket())
{
}

void
Nic_raw::Ethernet::_wait_for_packet()
{
    int rv;
    fd_set read_fds;
    
    FD_ZERO (&read_fds);
    FD_SET (_fd, &read_fds);
    do
    {
        rv = select (_fd + 1, &read_fds, NULL, NULL, NULL);
    } while (rv < 0);
}

int
Nic_raw::Ethernet::_open_socket()
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

ssize_t
Nic_raw::Ethernet::_write(const void *buffer, size_t size)
{
    return write(_fd, buffer, size);
}

ssize_t
Nic_raw::Ethernet::_read(void *buffer, size_t size)
{
    return read(_fd, buffer, size);
}
