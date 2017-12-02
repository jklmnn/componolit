/*
 * \brief Helper class to log arbitrary memory ojects
 * \author Johannes Kliemann
 * \date 2017-11-23
 */

/*
 * Copyright (C) 2017 Componolit GmbH
 *
 * This file is part of the Componolit platform, which is distributed
 * under the terms of the GNU Affero General Public License version 3.
 */


#ifndef _BUFFER_DUMP_H_
#define _BUFFER_DUMP_H_

#include <base/log.h>


template <typename T, unsigned csize = 2>
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
            Genode::size_t i = 0;
            for(; i < size; ++i){
                Genode::print(out, Genode::Hex(buffer[i],
                            Genode::Hex::OMIT_PREFIX,
                            Genode::Hex::PAD));
                Genode::print(out, ((i + 1) % sizeof(T)) ? "" : " ");
                Genode::print(out, ((i + 1) % (8 * csize)) ? "" : "\n");
            }
            Genode::print(out, (i < (8 * csize)) ? "\n" : "", "<--");
        }
};

#endif //_BUFFER_DUMP_H_
