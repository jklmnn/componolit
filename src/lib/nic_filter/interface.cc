/*
 * \brief  A net interface in form of a signal-driven NIC-packet handler
 * \author Martin Stein
 * \date   2017-03-08
 */

/*
 * Copyright (C) 2016-2017 Genode Labs GmbH
 *
 * This file is part of the Genode OS framework, which is distributed
 * under the terms of the GNU Affero General Public License version 3.
 */

/* local includes */
#include <interface.h>

using namespace Net;
using namespace Genode;

static int iface_id = 0;

void Interface::_handle_packet(void              *const  base,
                            size_t             const  size,
                            Packet_descriptor  const &pkt)
{
	try {
		Interface &remote = _remote.deref();
		remote._send(base, size);
	}
	catch (Pointer<Interface>::Invalid) {
		error("no remote interface set"); }
}


void Interface::_send(void *base, Genode::size_t const size)
{
	try {
                Nic_filter::direction_t dir = Nic_filter::UNKNOWN;
                if(_label == String<64>("bp"))
                    dir = Nic_filter::UP;
                if(_label == String<64>("ap"))
                    dir = Nic_filter::DOWN;
                _filter.filter(base, size, dir, _id);
                /*
		Packet_descriptor const pkt = _source().alloc_packet(fsize);
		char *content = _source().packet_content(pkt);
		Genode::memcpy((void *)content, (void*)buffer, fsize);
		_source().submit_packet(pkt);
                */
	}
	catch (Packet_stream_source::Packet_alloc_failed) {
		error("Failed to allocate packet"); }
}

void Interface::submit(void *buffer, Genode::size_t size, void *iface)
{
    Interface *ifc = (Interface *)iface;
    Packet_descriptor const pkt = ifc->_source().alloc_packet(size);
    void *content = ifc->_source().packet_content(pkt);
    Genode::memcpy(content, buffer, size);
    ifc->_source().submit_packet(pkt);
}

void Interface::_ready_to_submit()
{
	while (_sink().packet_avail()) {

		Packet_descriptor const pkt = _sink().get_packet();
		if (!pkt.size()) {
			continue; }

		_handle_packet(_sink().packet_content(pkt), pkt.size(), pkt);

		if (!_sink().ready_to_ack()) {
			error("ack state FULL");
			return;
		}
		_sink().acknowledge_packet(pkt);
	}
}


void Interface::_ready_to_ack()
{
	while (_source().ack_avail()) {
		_source().release_packet(_source().get_acked_packet()); }
}


Interface::Interface(Entrypoint        &ep,
                     Interface_label    label,
                     Timer::Connection &timer,
                     Duration          &curr_time,
                     bool               log_time,
                     Allocator         &alloc,
                     Nic_filter::Filter &filter)
:
	_sink_ack     (ep, *this, &Interface::_ack_avail),
	_sink_submit  (ep, *this, &Interface::_ready_to_submit),
	_source_ack   (ep, *this, &Interface::_ready_to_ack),
	_source_submit(ep, *this, &Interface::_packet_avail),
	_alloc(alloc), _label(label), _timer(timer), _curr_time(curr_time),
        _filter(filter),
        _id(++iface_id),
        _filter_if(_filter.registry(), this, &Interface::submit, _id),
	_log_time(log_time)
{ }
