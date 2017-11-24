
extern "C" void nic_filter__filter(void*, const void*, const int, const int);

// gnat exceptions

extern "C" void __gnat_last_chance_handler()
{
    Genode::warning(__func__, " not implemented");
}
