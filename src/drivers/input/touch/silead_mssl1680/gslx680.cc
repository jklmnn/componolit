
#include <gslx680.h>

using namespace GSL;

X680::X680(DW::I2C *_i2c, Genode::Env &env, void *_acpi, int(*_enable_acpi)(void*, bool), Genode::uint16_t addr, Genode::uint32_t irq, Genode::uint32_t gpio_irq) :
    config(env, "config"),
    firmware(env, config.xml().sub_node("firmware").attribute_value("name", Genode::String<128>()).string()),
    _addr(addr),
    _irq(env, irq),
    _gpio_irq(env, gpio_irq),
    _timer(env),
    msgs(addr)
{
    fw_header = firmware.local_addr<FW::header>();
    fw_page = (FW::page*)&(firmware.local_addr<Genode::uint8_t>()[sizeof(FW::header)]);
    char *magic = firmware.local_addr<char>();
    char mstr[9];
    for(int i = 0; i < 9; ++i)
        mstr[i] = magic[i];
    Genode::String<9>gmstr = Genode::String<9>(mstr);
    Genode::log("Firmware device: ", gmstr);
    if(fw_header->magic != FW::MAGIC || fw_header->model != FW::MODEL){
        Genode::error("Unsupported firmware.");
        throw FW::InvalidFirmware();
    }
    _sigh.construct(env.ep(), *this, &X680::handle_irq);
    _irq.sigh(*_sigh);
    _gpio_sigh.construct(env.ep(), *this, &X680::handle_gpio);
    _gpio_irq.sigh(*_gpio_sigh);
    Genode::log("Setting up touch device");
    acpi = _acpi;
    enable_acpi = _enable_acpi;
    i2c = _i2c;
    _addr = addr;
    _irq.ack_irq();
    _gpio_irq.ack_irq();
    enable(false);
    enable(true);
}

void X680::setup()
{
    _timer.usleep(50000);

    i2c->send(&msgs.reset_1);
    _timer.usleep(20000);
    i2c->send(&msgs.reset_2);
    _timer.usleep(20000);
    i2c->send(&msgs.reset_3);
    _timer.usleep(20000);
    
    //flash_firmware();
    
    i2c->send(&msgs.startup);
    _timer.usleep(20000);
    Genode::log("Touch device ready.");
}

void X680::flash_firmware()
{
    Genode::log("Writing firmware...");
    for(Genode::uint32_t i = 0; i < fw_header->pages; ++i){

        Genode::uint8_t p_buf[5];
        p_buf[0] = 0xf0;
        Genode::memcpy(&p_buf[1], (Genode::uint8_t*)&(fw_page[i].address), 4);
        DW::Message page {_addr, 0x0, 5, p_buf};
        Genode::Fifo_element<DW::Message> page_msg { &page };
        i2c->send(&page_msg);
        
        Genode::uint8_t d_buf[fw_page[i].size + 1];
        d_buf[0] = 0;
        Genode::memcpy(&d_buf[1], fw_page[i].data, fw_page[i].size);
        DW::Message data {_addr, 0x0, (Genode::uint16_t)(fw_page[i].size + 1), d_buf};
        Genode::Fifo_element<DW::Message> data_msg { &data };
        i2c->send(&data_msg);
        
        while(page.len - page.status || data.len - data.status)
            _timer.usleep(1000);
    }
}       

void X680::enable(bool e)
{
    enable_acpi(acpi, e);
}

DW::I2C *X680::driver()
{
    return i2c;
}

