
extern "C" void nic_filter__test(int);
extern "C" void nic_filter__filter(const char*, const char*, int, int);

// gnat exceptions

extern "C" void __gnat_last_chance_handler()
{
    Genode::warning(__func__, " not implemented");
}
