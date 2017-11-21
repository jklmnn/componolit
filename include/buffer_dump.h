
#ifndef _BUFFER_DUMP_H_
#define _BUFFER_DUMP_H_

#include <base/log.h>


template <typename T, int csize = 2>
class Buffer_dump
{
    private:
        const Genode::uint8_t *buffer;
        const Genode::size_t size;
    public:
        Buffer_dump(const T *b, const Genode::size_t s) :
            buffer(reinterpret_cast<const Genode::uint8_t*>(b)),
            size(s * sizeof(T))
            { }
        void print(Genode::Output &out) const
        {
            Genode::print(out, "--> ", Genode::Hex((long long)(void*)buffer), "\n");
            for(Genode::size_t i = 0; i < size; ++i){
                Genode::print(out, Genode::Hex(buffer[i],
                            Genode::Hex::OMIT_PREFIX,
                            Genode::Hex::PAD));
                Genode::print(out, ((i + 1) % sizeof(T)) ? "" : " ");
                Genode::print(out, ((i + 1) % (8 * csize)) ? "" : "\n");
            }
            Genode::print(out, "\n<--");
        }
};

#endif //_BUFFER_DUMP_H_
