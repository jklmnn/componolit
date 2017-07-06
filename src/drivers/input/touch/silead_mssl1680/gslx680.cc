
#include <gslx680.h>

using namespace GSL;

X680::X680(DW::I2C *_i2c, Genode::Env &env, void *_acpi, int(*_enable_acpi)(void*, bool), Genode::uint16_t addr, Genode::uint32_t irq) :
    config(env, "config"),
    firmware(env, config.xml().sub_node("firmware").attribute_value("name", Genode::String<128>()).string()),
    _irq(env, irq),
    msgs(addr)
{
    _sigh.construct(env.ep(), *this, &X680::handle_irq);
    _irq.sigh(*_sigh);
    Genode::log("Setting up touch device");
    acpi = _acpi;
    enable_acpi = _enable_acpi;
    i2c = _i2c;
    _addr = addr;
    setup();
    Genode::log("Touch device ready.");
    _irq.ack_irq();
}

void X680::setup()
{
//    enable(false);
    enable(true);

    i2c->send(&msgs.reset_1);
    i2c->send(&msgs.reset_2);
    i2c->send(&msgs.reset_3);
    i2c->send(&msgs.startup);

//    i2c->send(&msgs.test);
}

void X680::enable(bool e)
{
    enable_acpi(acpi, e);
}

DW::I2C *X680::driver()
{
    return i2c;
}

