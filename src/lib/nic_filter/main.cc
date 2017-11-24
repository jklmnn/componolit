/*
 * \brief  Bump-in-the-wire component to dump NIC traffic info to the log
 * \author Martin Stein
 * \date   2017-03-08
 */

/*
 * Copyright (C) 2016-2017 Genode Labs GmbH
 *
 * This file is part of the Genode OS framework, which is distributed
 * under the terms of the GNU Affero General Public License version 3.
 */

/* Genode */
#include <base/component.h>

/* local includes */
#include <nic_filter.h>

using namespace Genode;

class Main
{
	private:

            Env &_env;

            Nic_filter::Filter _filter;

            Nic_filter::Nic_filter _nf;

	public:

		Main(Env &env);
};


Main::Main(Env &env)
: _env(env), _nf(env, _filter) { }


void Component::construct(Env &env)
{
    Genode::log("nic_dump_filter");
	/* XXX execute constructors of global statics */
	env.exec_static_constructors();

	static Main main(env);
}
