
#include <filter.h>

Nic_filter::Filter::Root::Root(Genode::Env &env,
     Genode::Allocator &md_alloc,
     Nic_filter::Filter *filter)
:
        Genode::Root_component<Nic_filter::Filter::Session>(&env.ep().rpc_ep(), &md_alloc),
        _env(env),
        _filter(filter)
{}

Nic_filter::Filter::Session *Nic_filter::Filter::Root::_create_session(char const *args)
{
    Genode::size_t ram_quota   = Genode::Arg_string::find_arg(args, "ram_quota"  ).ulong_value(0) * 6;
    Genode::size_t tx_buf_size = Genode::Arg_string::find_arg(args, "tx_buf_size").ulong_value(0) * 10;
    Genode::size_t rx_buf_size = Genode::Arg_string::find_arg(args, "rx_buf_size").ulong_value(0);

        /* deplete ram quota by the memory needed for the session structure */
    Genode::size_t session_size = Genode::max(4096UL, (Genode::size_t)sizeof(Nic_filter::Filter::Session));
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

        return new (md_alloc()) Nic_filter::Filter::Session(tx_buf_size, rx_buf_size,
                                                  *md_alloc(), _env, _filter);
}
