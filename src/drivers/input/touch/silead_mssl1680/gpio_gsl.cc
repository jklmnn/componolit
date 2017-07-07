
#include <gpio_gsl.h>

using namespace GSL;

GPIO::Pin::Pin(Genode::Env &env, struct GSL::gpio_desc *desc) :
    Genode::Attached_io_mem_dataspace(env, desc->base, desc->length, true),
    Genode::Mmio((Genode::addr_t)&(((pin_t*)((Genode::addr_t)local_addr<Genode::addr_t>()))[GPIO::pin_map[desc->pin]]))
{ }

void GPIO::Pin::set(bool enable)
{
    VAL::access_t reg = read<VAL>();
    VAL::set(&reg, enable);
    write<VAL>(reg);
}
