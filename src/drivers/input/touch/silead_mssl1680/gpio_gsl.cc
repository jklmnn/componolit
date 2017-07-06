
#include <gpio_gsl.h>

using namespace GSL;

GPIO::Pin::Pin(Genode::addr_t base, Genode::uint16_t _pin) :
    Genode::Mmio((Genode::addr_t)&(((pin_t*)base)[GPIO::pin_map[_pin]])),
    address(base),
    pin(_pin),
    offset(GPIO::pin_map[pin])
{
    Genode::log("Using GPIO pin ", pin, " @ ", (void*)(offset * 0x10), " with config ", (void*)read<CON>());
}

void GPIO::Pin::set(bool enable)
{
    VAL::access_t reg = read<VAL>();
    Genode::log("pre-set=", (void*)reg);
    VAL::set(&reg, enable);
    Genode::log("post-set=", (void*)reg);
    write<VAL>(reg);
    Genode::log("post-write=", (void*)read<VAL>());
}
