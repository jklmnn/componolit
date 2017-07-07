
#pragma once

#include <irq_session/connection.h>
#include <base/heap.h>
#include <base/signal.h>
#include <base/attached_rom_dataspace.h>
#include <util/reconstructible.h>
#include <timer_session/connection.h>

#include <i2c_designware.h>
#include <acpi_gsl.h>
#include <gpio_gsl.h>

namespace GSL{
    namespace FW {
        struct header{
            Genode::uint32_t magic;
            Genode::uint32_t model;
            Genode::uint16_t version;
            Genode::uint16_t touches;
            Genode::uint16_t width;
            Genode::uint16_t height;
            Genode::uint8_t swapped;
            Genode::uint8_t xflipped;
            Genode::uint8_t yflipped;
            Genode::uint8_t tracking;
            Genode::uint32_t pages;
        } __attribute__((packed));
        struct page {
            Genode::uint8_t address[2];
            Genode::uint16_t size;
            Genode::uint8_t data[128];
        } __attribute__((packed));
        enum {
            MAGIC = 0x584c5347,
            MODEL = 0x30383631,
            VERSION = 1
        };
        class InvalidFirmware : Genode::Exception { };
    };
    enum {
        REG_ZERO = 0x00,
        REG_STATUS = 0xe0,
        REG_PAGE = 0xf0,
        REG_TOUCH_STATUS = 0xbc,
        REG_UNKNOWN = 0xe4
    };
    enum {
        S_IDLE = 0,
        S_RDY = 1,
        S_RST1 = 2,
        S_RST2 = 3,
        S_RST3 = 4,
        S_FW_ADR = 5,
        S_FW_DATA = 6,
        S_STARTUP = 7
    };
    class X680;
};

class GSL::X680 : DW::Message_callback {

private:

    Genode::uint8_t rst1[1] = { 0x88 };
    Genode::uint8_t rst2[1] = { 0x04 };
    Genode::uint8_t rst3[4] = { 0x00, 0x00, 0x00, 0x00 };
    Genode::uint8_t strt[1] = { 0x00 };
    Genode::uint32_t current_page = 0;

    Genode::Heap _heap;
    Genode::Attached_rom_dataspace config;
    Genode::Attached_rom_dataspace firmware;
    Genode::Irq_connection _irq;
    Genode::Constructible<Genode::Signal_handler<GSL::X680>> _sigh;
    Timer::Connection _timer;

    struct GSL::gslx_desc *_desc;
    DW::I2C *_i2c;
    GSL::Acpi *_acpi;
    GSL::GPIO::Pin *_pin;
    GSL::FW::header *fw_header;
    GSL::FW::page *fw_page;
    bool is_initialized = false;
    void setup();
    void enable(bool);
    void flash_firmware();
    void write(Genode::uint8_t, Genode::uint8_t*, Genode::size_t, int);
    void read(Genode::uint8_t, Genode::uint8_t*, Genode::size_t, int);
public:
    X680(Genode::Env&, DW::I2C*, GSL::Acpi*, GSL::GPIO::Pin*, struct GSL::gslx_desc*);
    inline void handle_irq(){
        Genode::log("GSLX IRQ");
        if(!is_initialized)
            setup();
        _irq.ack_irq();
        Genode::log("finished GSLX IRQ");
    }
    void callback(int, DW::Message*) override;
};
