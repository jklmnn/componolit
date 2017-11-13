/*
 * \brief  LOG service that logs to another LOG service
 * \author Alexander Senier
 * \date   2017-10-28
 */

/*
 * Copyright (C) 2017 Componolit GmbH
 *
 * This file is part of the Componolit platform, which is distributed
 * under the terms of the GNU Affero General Public License version 3.
 */

#include <root/component.h>
#include <base/component.h>
#include <base/heap.h>

#include <log_session/log_session.h>
#include <log_session/connection.h>

namespace Genode {

	class Bufferedlog_component : public Rpc_object<Log_session>
	{
		public:

			enum { LABEL_LEN = 64 };

		private:

			Log_connection _log;

		public:

			/**
			 * Constructor
			 */
			Bufferedlog_component(const char *label, Genode::Env &env)
			: _log(env, Session_label(label)) { }

			/*****************
			 ** Log session **
			 *****************/

			/**
			 * Write a log-message to upstream log session
			 */
			size_t write(String const &string_buf)
			{
				if (!(string_buf.valid_string())) {
					Genode::error("corrupted string");
					return 0;
				}

				char const *string = string_buf.string();
				int len = strlen(string);

				_log.write(string);
				return len;
			}
	};

	class Bufferedlog_root : public Root_component<Bufferedlog_component>
	{
		private:

			Genode::Env &_env;

		protected:

			/**
			 * Root component interface
			 */
			Bufferedlog_component *_create_session(const char *args)
			{
				char label_buf[Bufferedlog_component::LABEL_LEN];

				Arg label_arg = Arg_string::find_arg(args, "label");
				label_arg.string(label_buf, sizeof(label_buf), "");

				return new (md_alloc()) Bufferedlog_component(label_buf, _env);
			}

		public:

			/**
			 * Constructor
			 *
			 * \param session_ep  entry point for managing cpu session objects
			 * \param md_alloc    meta-data allocator to be used by root component
			 */
			Bufferedlog_root(Genode::Env &env, Allocator &md_alloc)
			: Root_component<Bufferedlog_component>(env.ep(), md_alloc), _env(env) { }
	};
}

void Component::construct(Genode::Env &env)
{
	using namespace Genode;

	static Sliced_heap session_alloc(env.ram(), env.rm());
	static Genode::Bufferedlog_root bufferedlog_root(env, session_alloc);

	env.parent().announce(env.ep().manage(bufferedlog_root));
}
