
#include <acpi_gsl.h>

using namespace GSL;

static struct Irq irq;

Acpi::Acpi(Genode::Env &env) : 
    env(env),
    sci_irq(env.ep(), *this, &Acpi::irq_handler)
{
    Genode::log("Initializing ACPI");
    Acpica::init(env, heap); 
    init_acpi();
}

void Acpi::init_acpi()
{

//    Genode::log("AcpiInitializeSubsystem");
    ACPI_STATUS status = AcpiInitializeSubsystem();
    if (status != AE_OK) {
            Genode::error("AcpiInitializeSubsystem failed, status=", status);
            return;
    }

//    Genode::log("AcpiInitializeTables");
    status = AcpiInitializeTables(nullptr, 0, true);
    if (status != AE_OK) {
            Genode::error("AcpiInitializeTables failed, status=", status);
            return;
    }

//    Genode::log("AcpiLoadTables");
    status = AcpiLoadTables();
    if (status != AE_OK) {
            Genode::error("AcpiLoadTables failed, status=", status);
            return;
    }

//    Genode::log("AcpiEnableSubsystem");
    status = AcpiEnableSubsystem(ACPI_FULL_INITIALIZATION);
    if (status != AE_OK) {
            Genode::error("AcpiEnableSubsystem failed, status=", status);
            return;
    }

//    Genode::log("AcpiInitializeObjects");
    status = AcpiInitializeObjects(ACPI_NO_DEVICE_INIT);
    if (status != AE_OK) {
            Genode::error("AcpiInitializeObjects (no devices) failed, status=", status);
            return;
    }

//    Genode::log("AcpiInitializeObjects");
    status = AcpiInitializeObjects(ACPI_FULL_INITIALIZATION);
    if (status != AE_OK) {
            Genode::error("AcpiInitializeObjects (full init) failed, status=", status);
            return;
    }

//    Genode::log("AcpiUpdateAllGpes");
    status = AcpiUpdateAllGpes();
    if (status != AE_OK) {
            Genode::error("AcpiUpdateAllGpes failed, status=", status);
            return;
    }

//    Genode::log("AcpiEnableAllRuntimeGpes");
    status = AcpiEnableAllRuntimeGpes();
    if (status != AE_OK) {
            Genode::error("AcpiEnableAllRuntimeGpes failed, status=", status);
            return;
    }

//    Genode::log("AcpiGetDevices: MSSL1680");
    /* Detect touch controller */
    bool device_found = false;
    void *df = (void*)&device_found;
    status = AcpiGetDevices(ACPI_STRING("MSSL1680"), Acpi::init_gslx680, this, &df);
    if (status != AE_OK) {
            Genode::error("AcpiGetDevices (MSSL1680) failed, status=", status);
            return;
    }
    if(device_found)
        Genode::log("ACPI initialization finished");
    else
        Genode::error("No touch device available");
}

ACPI_STATUS Acpi::init_gslx680(ACPI_HANDLE mssl1680, UINT32, void* self, void** device_found)
{
    Genode::log("Initializing device");
    (*(bool*)*device_found) = true;
    ACPI_BUFFER acpi_name;
    char name_buf[5];
    acpi_name.Length = 5;
    acpi_name.Pointer = name_buf;
    ACPI_STATUS status = AcpiGetName(mssl1680, ACPI_SINGLE_NAME, &acpi_name);
    if(status == AE_OK){
        Genode::String <5>a_n = Genode::String<5>(name_buf);
        Genode::log("Detected MSSL1680 as ", a_n);
        ((Acpi*)self)->MSSL1680 = mssl1680;
        status = ((Acpi*)self)->load_resources(mssl1680);
    }else{
        Genode::error("Detected MSSL1680 as unkown");
    }

    return status;
}

ACPI_STATUS Acpi::load_resources(ACPI_HANDLE gsl)
{
    Genode::log("Loading resources");
    ACPI_BUFFER buffer;
    ACPI_HANDLE i2c_h, gpio_h;
    buffer.Length = ACPI_ALLOCATE_BUFFER;

    ACPI_STATUS status = AcpiEvaluateObject(gsl, (ACPI_STRING)"_CRS", nullptr, &buffer);
    if(status == AE_OK){
        GSL::Resource::I2C_serial_bus res_i2c(buffer.Pointer, buffer.Length);
        GSL::Resource::Extended_Interrupt res_irq(buffer.Pointer, buffer.Length);
        gslx.slv_addr = res_i2c.address();
        gslx.irq = res_irq.irq();
        GSL::Resource::Gpio_connection gpcon(buffer.Pointer, buffer.Length);
        gpio.pin = gpcon.pin(0);

        status = AcpiGetHandle(NULL, res_i2c.resource_source(), &i2c_h);

        if(AE_OK == AcpiGetHandle(NULL, gpcon.resource_source(), &gpio_h)){
            AcpiOsFree(buffer.Pointer);
            buffer.Length = ACPI_ALLOCATE_BUFFER;
            if(AE_OK == AcpiEvaluateObject(gpio_h, (ACPI_STRING)"_CRS", nullptr, &buffer)){
                try{
                    GSL::Resource::Fixed_mem_range_32 gpio_mem(buffer.Pointer, buffer.Length);
                    gpio.base = gpio_mem.address();
                    gpio.length = gpio_mem.length();
                    GSL::Resource::Extended_Interrupt gpio_intr(buffer.Pointer, buffer.Length);
                    gpio.irq = gpio_intr.irq();
                }catch (Resource::ResourceNotFound&) {}
            }
        }

        AcpiOsFree(buffer.Pointer);
        if(status == AE_OK){
            buffer.Length = ACPI_ALLOCATE_BUFFER;
            status = AcpiEvaluateObject(i2c_h, (ACPI_STRING)"_CRS", nullptr, &buffer);
            if(status == AE_OK){
                GSL::Resource::Fixed_mem_range_32 res_mem(buffer.Pointer, buffer.Length);
                GSL::Resource::Extended_Interrupt res_i2c_irq(buffer.Pointer, buffer.Length);
                i2c.base = res_mem.address();
                i2c.length = res_mem.length();
                i2c.irq = res_i2c_irq.irq();
            }
            AcpiOsFree(buffer.Pointer);
        }else{
            Genode::error("Failed to get I2C device");
            throw DeviceNotFound(); 
        }
    }

    return status;
}

/*
void Acpi::initialize_driver(Genode::addr_t base, Genode::uint32_t length,
        Genode::uint32_t i2c_irq, Genode::uint16_t i2c_slv_adr, Genode::uint32_t mssl_irq,
        Genode::addr_t gpio_base, Genode::uint32_t gpio_length, Genode::uint16_t gpio_pin, Genode::uint32_t gpio_irq)
{
    Genode::log("Initializing driver with");
    Genode::log("I2C controller: ", (void*)base, " - ", (void*)(base + length), ", ", i2c_irq);
    Genode::log("MSSL1680 controller: ", (void*)(Genode::addr_t)i2c_slv_adr, ", ", mssl_irq);
    if(gpio_base && gpio_pin){
        Genode::log("GPIO controller: ", (void*)gpio_base, " - ", (void*)(gpio_base + gpio_length), ", ", gpio_pin, ", ", (void*)(GPIO::pin_map[gpio_pin] * 0x10 + gpio_base));
        gpio_mem.construct(
            env,
            gpio_base,
            gpio_length,
            true);
        pin.construct(
            (Genode::addr_t)gpio_mem->local_addr<Genode::addr_t>(),
            gpio_pin
            );
    }else{
        Genode::warning("GPIO not available");
    }
    i2c_mem.construct(
        env,    
        base, //0x48d0e000,
        length, //0xfff,
        true);
    i2c.construct(
        (Genode::addr_t)i2c_mem->local_addr<Genode::addr_t>(),
        i2c_irq,
        env,
        base,
        length);
    x680.construct(
        &*i2c,
        env,
        (void*)this,
        &Acpi::enable_mssl1680,
        i2c_slv_adr,
        mssl_irq,
        gpio_irq);
}
*/

void Acpi::irq_handler()
{
    if(!irq.handler)
        return;

    UINT32 res = irq.handler(irq.context);
    sci_conn->ack_irq();
    AcpiOsWaitEventsComplete();
}

int Acpi::enable_mssl1680(bool enable)
{
    char _psx[5] = {'_', 'P', 'S', (enable) ? '0' : '3', '\0'};
    ACPI_STATUS status = AcpiEvaluateObject(MSSL1680, (ACPI_STRING)"_PS0", nullptr, nullptr);
    if(status != AE_OK)
        Genode::warning("Failed to enable device via ACPI, reason=", status);
/*
        if(((Acpi*)acpi)->pin.constructed()){
            Genode::log("Enabling device via GPIO");
            ((Acpi*)acpi)->pin->set(enable);
            return 0;
        }
*/
    return status;
}

i2c_desc *Acpi::get_i2c()
{
    return &i2c;
}

gslx_desc *Acpi::get_gslx()
{
    return &gslx;
}

gpio_desc *Acpi::get_gpio()
{
    return &gpio;
}

void Resource::I2C_serial_bus::parse()
{
    Genode::uint8_t *data = (Genode::uint8_t*)buffer;
    for(Genode::size_t i = 0; i < size; ++i)
        if(data[i] == (Genode::uint8_t)Resource::LARGE::GENERIC_SERIAL_BUS)
            if(check_valid(&data[i])){
                return;
            }
    throw Resource::ResourceNotFound();
}

bool Resource::I2C_serial_bus::check_valid(Genode::uint8_t *start)
{
    desc = (struct Resource::I2C_serial_bus_description *)start;
    return     desc->tag == (Genode::uint8_t)Resource::LARGE::GENERIC_SERIAL_BUS
            && desc->size >= 0xf
            && desc->size < size
            && desc->revision_id == 1
            && desc->source_index == 0
            && desc->bus_type == 1
            && desc->specific_flags == 0
            && desc->specific_revision == 1
            && desc->type_data_length >= 0x6;
}

Genode::uint16_t Resource::I2C_serial_bus::address()
{
    return desc->address;
}

Genode::uint32_t Resource::I2C_serial_bus::speed()
{
    return desc->speed;
}

ACPI_STRING Resource::I2C_serial_bus::resource_source()
{
    return (ACPI_STRING)&((&(desc->vendor_data))[desc->type_data_length - 6]);
}

void Resource::Extended_Interrupt::parse()
{
    Genode::uint8_t *data = (Genode::uint8_t*)buffer;
    for(Genode::size_t i = 0; i < size; ++i)
        if(data[i] == (Genode::uint8_t)Resource::LARGE::EXT_IRQ){
            desc = (Resource::Extended_interrupt_description*)&data[i];
            if(desc->tag == (Genode::uint8_t)Resource::LARGE::EXT_IRQ
            && desc->size >= 0x6
            && desc->size < size
            && desc->irq_count == 1)
                return;
        }
    throw Resource::ResourceNotFound();
}

Genode::uint32_t Resource::Extended_Interrupt::irq()
{
    return desc->irq;
}

void Resource::Fixed_mem_range_32::parse()
{
    Genode::uint8_t *data = (Genode::uint8_t*)buffer;
    for(Genode::size_t i = 0; i < size; ++i)
        if(data[i] == (Genode::uint8_t)Resource::LARGE::FIXED_MEM_RANGE_32){
            desc = (Resource::Fixed_mem_range_32_description*)&data[i];
            if(desc->tag == (Genode::uint8_t)Resource::LARGE::FIXED_MEM_RANGE_32
            && desc->size == 0x9)
                return;
        }
    throw Resource::ResourceNotFound();
}

Genode::addr_t Resource::Fixed_mem_range_32::address()
{
    return (Genode::addr_t)desc->address;
}

Genode::uint32_t Resource::Fixed_mem_range_32::length()
{
    return desc->length;
}

bool Resource::Fixed_mem_range_32::writable()
{
    return (bool)desc->info;
}

void Resource::Gpio_connection::parse()
{
    Genode::uint8_t *data = (Genode::uint8_t*)buffer;
    for(Genode::size_t i = 0; i < size; ++i)
        if(data[i] == (Genode::uint8_t)Resource::LARGE::GPIO){
            desc = (Resource::Gpio_connection_description*)&data[i];
            if(desc->tag == (Genode::uint8_t)Resource::LARGE::GPIO
            && desc->size >= 0x16
            && desc->revision_id == 1)
                return;
        } 
    throw Resource::ResourceNotFound();
}

Genode::uint32_t Resource::Gpio_connection::pin_count()
{
    return (desc->src_name_offset - desc->pin_table_offset)/2; 
}

Genode::uint16_t Resource::Gpio_connection::pin(Genode::uint32_t p)
{
    return ((Genode::uint16_t*)&(((Genode::uint8_t*)desc)[desc->pin_table_offset]))[p];
}

ACPI_STRING Resource::Gpio_connection::resource_source()
{
    return (ACPI_STRING)&((Genode::uint8_t*)desc)[desc->src_name_offset];
}


// APCI C definitions

ACPI_STATUS AcpiOsInstallInterruptHandler(UINT32 i, ACPI_OSD_HANDLER h, void* c)
{
    irq.irq = i;
    irq.handler = h;
    irq.context = c;
    return AE_OK;
}

#include <base/printf.h>

extern "C" {

    void AcpiOsPrintf(const char *fmt, ...)
    {}

    void AcpiOsVprintf(const char *fmt, va_list va)
    {}
}
