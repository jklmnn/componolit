
#include <base/component.h>
#include <base/attached_io_mem_dataspace.h>

#include <acpi_gsl.h>
#include <i2c_designware.h>
#include <gpio_gsl.h>
#include <gslx680.h>

struct Main {

    Genode::Env &env;
    
    GSL::Acpi acpi { env };

    struct GSL::i2c_desc *i2c_d = acpi.get_i2c();
    struct GSL::gslx_desc *gslx_d = acpi.get_gslx();
    struct GSL::gpio_desc *gpio_d = acpi.get_gpio();

    DW::I2C i2c {
        env,
        i2c_d };

    GSL::GPIO::Pin pin {
        env,
        gpio_d };

    GSL::X680 gslx {
        env,
        &i2c,
        &acpi,
        &pin,
        gslx_d };

    Main(Genode::Env &env) : env(env)
    { }
};

void Component::construct(Genode::Env &env){

    static Main inst(env);
    env.exec_static_constructors();
}
