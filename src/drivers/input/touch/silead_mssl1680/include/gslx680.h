
#pragma once

#include <irq_session/connection.h>
#include <base/signal.h>
#include <base/attached_rom_dataspace.h>
#include <util/fifo.h>
#include <util/reconstructible.h>

#include <i2c_designware.h>

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
    };
    class X680;
    class Messages;
};

class GSL::Messages {

private:

public:
    Messages(Genode::uint16_t _addr){
        m_startup.addr = _addr;
        m_reset_1.addr = _addr;
        m_reset_2.addr = _addr;
        m_reset_3.addr = _addr;
    }
    Genode::uint8_t data[11] = {
        0xe0, 0x00,
        0xe0, 0x88,
        0xe4, 0x04,
        0xbc, 0x00, 0x00, 0x00, 0x00
    };

    Genode::uint8_t test_data[100];

    DW::Message m_startup {0, 0, 2, &data[0]};
    DW::Message m_reset_1 {0, 0, 2, &data[2]};
    DW::Message m_reset_2 {0, 0, 2, &data[4]};
    DW::Message m_reset_3 {0, 0, 5, &data[6]};
    DW::Message m_test {0x40, 0, 40, test_data};

    Genode::Fifo_element<DW::Message> startup { &m_startup };
    Genode::Fifo_element<DW::Message> reset_1 { &m_reset_1 };
    Genode::Fifo_element<DW::Message> reset_2 { &m_reset_2 };
    Genode::Fifo_element<DW::Message> reset_3 { &m_reset_3 };
    Genode::Fifo_element<DW::Message> test { &m_test };

};


class GSL::X680 {

private:

    Genode::Attached_rom_dataspace config;
    Genode::Attached_rom_dataspace firmware;
    Genode::uint16_t _addr;
    Genode::Irq_connection _irq;
    Genode::Constructible<Genode::Signal_handler<GSL::X680>> _sigh;
    DW::I2C *i2c;
    void setup();
    void *acpi;
    void enable(bool);
    int (*enable_acpi)(void*, bool);
    GSL::Messages msgs;

public:
    X680(DW::I2C*, Genode::Env&, void*, int(*)(void*, bool), Genode::uint16_t, Genode::uint32_t);
    DW::I2C *driver();
    inline void handle_irq(){
        Genode::log("GSLX IRQ");
        _irq.ack_irq();
    }
};
