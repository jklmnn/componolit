#ifndef _ETHERNET_H_H
#define _ETHERNET_H_H

// Genode includes
#include <base/attached_rom_dataspace.h>
#include <base/component.h>
#include <nic_session/nic_session.h>

// Linux includes
#include <sys/types.h>

namespace Nic_raw {
    class Ethernet;
	using namespace Genode;
}

class Nic_raw::Ethernet
{
    public:
        Ethernet(Env &env);

        void _wait_for_packet();
        ssize_t _write(const void *buffer, size_t size);
        ssize_t _read(void *buffer, size_t size);

    private:
		int _open_socket();

		Genode::Attached_rom_dataspace _config_rom;
		int _fd;
};

#endif // _ETHERNET_H_H
