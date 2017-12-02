
#include <buffer_dump.h>
#include <base/log.h>
#include <base/component.h>

struct Main
{
    Genode::uint8_t _buf8[200] {0};
    Genode::uint16_t _buf16[200] {0};
    Genode::uint32_t _buf32[200] {0};
    Genode::uint64_t _buf64[200] {0};

    Main(Genode::Env &)
    {
        Genode::log("--- test buffer dump ---");

        for(unsigned i = 0; i < 200; ++i){
            _buf8[i] = i;
            _buf16[i] = i;
            _buf32[i] = i;
            _buf64[i] = i;
        }

        Genode::log("u8: ", Buffer_dump<Genode::uint8_t>(_buf8, 200));
        Genode::log("u16: ", Buffer_dump<Genode::uint16_t>(_buf16, 200));
        Genode::log("u32: ", Buffer_dump<Genode::uint32_t>(_buf32, 200));
        Genode::log("u64: ", Buffer_dump<Genode::uint64_t>(_buf64, 200));

        Genode::log("-- buffer dump finished --");
    }
};

void Component::construct(Genode::Env &env)
{
    static Main main(env);
}
