
#include <base/component.h>

#include <acpi_gsl.h>

struct Main {

    Genode::Env &env;
    
    GSL::Acpi acpi { env };

    Main(Genode::Env &env) : env(env)
    { }
};

void Component::construct(Genode::Env &env){

    static Main inst(env);
    env.exec_static_constructors();
}
