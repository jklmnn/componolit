
#pragma once

#include <irq_session/connection.h>
#include <base/heap.h>
#include <base/signal.h>
#include <base/attached_rom_dataspace.h>
#include <util/fifo.h>
#include <util/reconstructible.h>
#include <timer_session/connection.h>

#include <i2c_designware.h>
#include <acpi_gsl.h>
#include <gpio_gsl.h>

namespace GSL{
    enum {
        IRQ = 68
    };
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
            Genode::uint16_t address;
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
    class X680;
    class Messages;
};

class GSL::Messages {

private:

public:
    Genode::uint8_t data[11] = {
        0xe0, 0x00,
        0xe0, 0x88,
        0xe4, 0x04,
        0xbc, 0x00, 0x00, 0x00, 0x00
    };

    DW::Message m_startup;
    DW::Message m_reset_1;
    DW::Message m_reset_2;
    DW::Message m_reset_3;

    Genode::Fifo_element<DW::Message> startup { &m_startup };
    Genode::Fifo_element<DW::Message> reset_1 { &m_reset_1 };
    Genode::Fifo_element<DW::Message> reset_2 { &m_reset_2 };
    Genode::Fifo_element<DW::Message> reset_3 { &m_reset_3 };
    
    Messages(Genode::uint16_t _addr) :
        m_startup (_addr, 0, 2, &data[0]),
        m_reset_1 (_addr, 0, 2, &data[2]),
        m_reset_2 (_addr, 0, 2, &data[4]),
        m_reset_3 (_addr, 0, 5, &data[6])
    { }
};


class GSL::X680 {

private:
    Genode::Heap fw_heap;
    Genode::Attached_rom_dataspace config;
    Genode::Attached_rom_dataspace firmware;
    Genode::Irq_connection _irq;
    Genode::Constructible<Genode::Signal_handler<GSL::X680>> _sigh;
    Timer::Connection _timer;
   
    struct GSL::gslx_desc *_desc;
    DW::I2C *_i2c;
    GSL::Acpi *_acpi;
    GSL::GPIO::Pin *_pin;
    GSL::Messages msgs;
    GSL::FW::header *fw_header;
    GSL::FW::page *fw_page;
    bool is_initialized = false;
    void setup();
    void enable(bool);
    void flash_firmware();

public:
    X680(Genode::Env&, DW::I2C*, GSL::Acpi*, GSL::GPIO::Pin*, struct GSL::gslx_desc*);
    inline void handle_irq(){
        Genode::log("GSLX IRQ");
        if(!is_initialized)
            setup();
        _irq.ack_irq();
        Genode::log("finished GSLX IRQ");
    }
};
