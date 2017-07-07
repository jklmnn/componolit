
#include <gslx680.h>

using namespace GSL;

X680::X680(Genode::Env  &env, DW::I2C *i2c, GSL::Acpi *acpi, GSL::GPIO::Pin *pin, struct GSL::gslx_desc *desc) :
    _heap(&env.ram(), &env.rm()),
    config(env, "config"),
    firmware(env, config.xml().sub_node("firmware").attribute_value("name", Genode::String<128>()).string()),
    _irq(env, desc->irq),
    _timer(env)
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
    write(REG_STATUS, rst1, 1, S_RST1);
}

void X680::enable(bool e)
{
    if(_acpi->enable_mssl1680(e))
        _pin->set(e);
}

void X680::write(Genode::uint8_t reg, Genode::uint8_t *data, Genode::size_t len, int return_status)
{
    DW::Message *msg = new (_heap) DW::Message(_desc->slv_addr, 0x0, len, reg, data, this, return_status);
    _i2c->send(msg);
}

void X680::read(Genode::uint8_t reg, Genode::uint8_t *data, Genode::size_t len, int return_status)
{ }

void X680::callback(int status, DW::Message *msg)
{
    int next = (current_page == (fw_header->pages - 1)) ? S_STARTUP : S_FW_ADR;
    switch(status){
        case S_RST1:
            _timer.usleep(10000);
            write(REG_UNKNOWN, rst2, 1, S_RST3);
            break;
        case S_RST2:
            _timer.usleep(10000);
            write(REG_TOUCH_STATUS, rst3, 4, S_RST3);
            break;
        case S_RST3:
            _timer.usleep(10000);
            Genode::log("Writing firmware");
        case S_FW_ADR:
            if(current_page < fw_header->pages)
                write(REG_PAGE, fw_page[current_page].address, sizeof(fw_page[current_page].address), S_FW_DATA);
            break;
        case S_FW_DATA:
            write(REG_ZERO, fw_page[current_page].data, sizeof(fw_page[current_page].data), next);
            ++current_page;
            break;
        case S_STARTUP:
            Genode::log("Starting up device");
            write(REG_STATUS, strt, 1, S_RDY);
            _timer.usleep(10000);
            is_initialized = true;
            Genode::log("GSLX initialized.");
        default:
            break;
    }
    _heap.free((void*)msg, sizeof(*msg));
}
