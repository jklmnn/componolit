
#include <gslx680.h>

using namespace GSL;

X680::X680(Genode::Env  &env, DW::I2C *i2c, GSL::Acpi *acpi, GSL::GPIO::Pin *pin, struct GSL::gslx_desc *desc) :
    fw_heap(&env.ram(), &env.rm()),
    config(env, "config"),
    firmware(env, config.xml().sub_node("firmware").attribute_value("name", Genode::String<128>()).string()),
    _irq(env, desc->irq),
    _timer(env),
    msgs(desc->slv_addr)
{
    _i2c = i2c;
    _acpi = acpi;
    _pin = pin;
    _desc = desc;
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
    Genode::log("Setting up touch device");
    _irq.ack_irq();
    enable(false);
    enable(true);
}

void X680::setup()
{
    _irq.ack_irq();
    Genode::log("Setting up device");
    Genode::log("Resetting device");
    _i2c->send(&msgs.reset_1);
    _i2c->send(&msgs.reset_2);
    _i2c->send(&msgs.reset_3);
    
    flash_firmware();
    
    Genode::log("Starting device");
    _i2c->send(&msgs.startup);
    Genode::log("Touch device ready.");
    is_initialized = true;
}

void X680::flash_firmware()
{
    Genode::log("Writing firmware...");
    for(Genode::uint32_t i = 0; i < fw_header->pages; ++i){

        Genode::uint8_t p_buf[5];
        p_buf[0] = 0xf0;
        Genode::memcpy(&p_buf[1], (Genode::uint8_t*)&(fw_page[i].address), 4);
        DW::Message *page = new (fw_heap) DW::Message(_desc->slv_addr, 0x0, 5, p_buf);
        _i2c->send(new (fw_heap) Genode::Fifo_element<DW::Message>(page));
        
        Genode::uint8_t d_buf[fw_page[i].size + 1];
        d_buf[0] = 0;
        Genode::memcpy(&d_buf[1], fw_page[i].data, fw_page[i].size);
        DW::Message *data  = new (fw_heap) DW::Message(_desc->slv_addr, 0x0, (Genode::uint16_t)(fw_page[i].size + 1), d_buf);
        _i2c->send(new (fw_heap) Genode::Fifo_element<DW::Message>(data));
    }
}       

void X680::enable(bool e)
{
    if(_acpi->enable_mssl1680(e))
        _pin->set(e);
}

