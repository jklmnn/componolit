
#pragma once

#include <base/heap.h>
#include <base/signal.h>
#include <base/attached_io_mem_dataspace.h>
#include <irq_session/connection.h>
#include <util/reconstructible.h>
#include <util/string.h>
#include <acpica/acpica.h>
#include <timer_session/connection.h>

extern "C" {
#include "acpi.h"
#include "accommon.h"
#include "acevents.h"
#include "acnamesp.h"
}

#include <i2c_designware.h>
#include <gslx680.h>
#include <gpio_gsl.h>

namespace GSL {
    class Acpi;
    struct Irq;
    namespace Resource {
        enum class SMALL {
            IRQ = 0x4,
            DMA = 0x5,
            S_DFD = 0x6,
            E_DFD = 0x7,
            IO_PORT = 0x8,
            FIXED_IO_PORT = 0x9,
            FIXED_DMA = 0xa,
            VENDOR = 0xe,
            END_TAG = 0xf
        };
        enum class LARGE {
            MEM_RANGE_24 = 0x81,
            GENERIC_REG = 0x82,
            VENDOR = 0x84,
            MEM_RANGE_32 = 0x85,
            FIXED_MEM_RANGE_32 = 0x86,
            DWORD_ADR = 0x87,
            WORD_ADR = 0x88,
            EXT_IRQ = 0x89,
            QWORD_ADR = 0x8a,
            EXT_ADR = 0x8b,
            GPIO = 0x8c,
            GENERIC_SERIAL_BUS = 0x8e
        };
        class Descriptor;
        class I2C_serial_bus;
        class Extended_Interrupt;
        class Fixed_mem_range_32;
        class Gpio_connection;
        class InvalidDataStructure : Genode::Exception {};
        class ResourceNotFound : Genode::Exception {};
        struct I2C_serial_bus_description;
        struct Extended_interrupt_description;
        struct Fixed_mem_range_32_description;
        struct Gpio_connection_description;
    };
};

struct GSL::Irq
{
    UINT32 irq;
    ACPI_OSD_HANDLER handler;
    void *context;
};

class GSL::Acpi
{
private:
    Genode::Env &env;
    Genode::Heap heap { env.ram(), env.rm() };

    Genode::Signal_handler<GSL::Acpi> sci_irq;
    Genode::Constructible<Genode::Irq_connection> sci_conn;
    Genode::Constructible<Genode::Attached_io_mem_dataspace> i2c_mem;
    Genode::Constructible<DW::I2C> i2c;
    Genode::Constructible<GSL::X680> x680;
    Genode::Constructible<Genode::Attached_io_mem_dataspace> gpio_mem;
    Genode::Constructible<GSL::GPIO::Pin> pin;

    ACPI_HANDLE MSSL1680;

    void init_acpi();
    static ACPI_STATUS init_gslx680(ACPI_HANDLE, UINT32, void*, void**);
    ACPI_STATUS load_resources(ACPI_HANDLE);
    void initialize_driver(Genode::addr_t, Genode::uint32_t, Genode::uint32_t, Genode::uint16_t, Genode::uint32_t, Genode::addr_t, Genode::uint32_t, Genode::uint16_t, Genode::uint32_t);
public:
    Acpi(Genode::Env &);
    void irq_handler();
    static int enable_mssl1680(void *, bool);
};

struct GSL::Resource::I2C_serial_bus_description {
    Genode::uint8_t tag;
    Genode::uint16_t size;
    Genode::uint8_t revision_id;
    Genode::uint8_t source_index;
    Genode::uint8_t bus_type;
    Genode::uint8_t general_flags;
    Genode::uint16_t specific_flags;
    Genode::uint8_t specific_revision;
    Genode::uint16_t type_data_length;
    Genode::uint32_t speed;
    Genode::uint16_t address;
    Genode::uint8_t vendor_data;
} __attribute__((packed));

struct GSL::Resource::Extended_interrupt_description {
    Genode::uint8_t tag;
    Genode::uint16_t size;
    Genode::uint8_t flags;
    Genode::uint8_t irq_count;
    Genode::uint32_t irq;
} __attribute__((packed));

struct GSL::Resource::Fixed_mem_range_32_description {
    Genode::uint8_t tag;
    Genode::uint16_t size;
    Genode::uint8_t info;
    Genode::uint32_t address;
    Genode::uint32_t length;
} __attribute__((packed));

struct GSL::Resource::Gpio_connection_description {
    Genode::uint8_t tag;
    Genode::uint16_t size;
    Genode::uint8_t revision_id;
    Genode::uint8_t type;
    Genode::uint16_t flags;
    Genode::uint16_t iio_flags;
    Genode::uint8_t pin_config;
    Genode::uint16_t output_drive;
    Genode::uint16_t debounce_timeout;
    Genode::uint16_t pin_table_offset;
    Genode::uint8_t src_index;
    Genode::uint16_t src_name_offset;
    Genode::uint16_t vendor_offset;
    Genode::uint16_t vendor_length;
} __attribute__((packed));

class GSL::Resource::Descriptor
{
private:
    virtual void parse() = 0;
protected:
    void *buffer;
    Genode::uint32_t size;
public:
    Descriptor(void* b, Genode::uint32_t s)
    {
        buffer = b;
        size = s;
    }
};

class GSL::Resource::I2C_serial_bus : GSL::Resource::Descriptor
{
private:
    void parse() override;
    bool check_valid(Genode::uint8_t*);
    struct GSL::Resource::I2C_serial_bus_description *desc;
public:
    I2C_serial_bus(void *buffer, Genode::uint32_t size) :
        GSL::Resource::Descriptor(buffer, size) { parse(); }
    Genode::uint16_t address();
    Genode::uint32_t speed();
    ACPI_STRING resource_source();
};

class GSL::Resource::Extended_Interrupt : GSL::Resource::Descriptor
{
private:
    void parse() override;
    struct GSL::Resource::Extended_interrupt_description *desc;
public:
    Extended_Interrupt(void *buffer, Genode::uint32_t size) :
        GSL::Resource::Descriptor(buffer, size) { parse(); }
    Genode::uint32_t irq();
};

class GSL::Resource::Fixed_mem_range_32 : GSL::Resource::Descriptor
{
private:
    void parse() override;
    struct GSL::Resource::Fixed_mem_range_32_description *desc;
public:
    Fixed_mem_range_32(void *buffer, Genode::uint32_t size) :
        GSL::Resource::Descriptor(buffer, size) { parse(); }
    Genode::addr_t address();
    Genode::uint32_t length();
    bool writable();
};

class GSL::Resource::Gpio_connection : GSL::Resource::Descriptor
{
private:
    void parse() override;
    struct GSL::Resource::Gpio_connection_description *desc;
public:
    Gpio_connection(void *buffer, Genode::uint32_t size) :
        GSL::Resource::Descriptor(buffer, size) { parse(); }
    Genode::uint32_t pin_count();
    Genode::uint16_t pin(Genode::uint32_t);
    ACPI_STRING resource_source();
};

// ACPI C declarations

ACPI_STATUS AcpiOsInstallInterruptHandler(UINT32, ACPI_OSD_HANDLER, void*);
