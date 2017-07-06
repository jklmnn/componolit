
#pragma once

#include <base/log.h>
#include <util/mmio.h>

namespace GSL {
    namespace GPIO{
        class Pin;
        typedef struct {
            Genode::uint32_t con;
            Genode::uint32_t mux;
            Genode::uint32_t val;
            Genode::uint32_t rvd;
        } pin_t;
        static const Genode::uint16_t pin_map[28] {
            19, 18, 17, 20, 21, 22, 24, 25, 23, 16,
            14, 15, 12, 26, 27,  1,  4,  8, 11,  0,
             3,  6, 10, 13,  2,  5,  9,  7,
        };
    };
};

class GSL::GPIO::Pin : Genode::Mmio
{
    struct CON  : Register<0x0, 32>{
        struct PIN_MUX      : Bitfield< 0,  3> {};
        struct LOCAL_MASK   : Bitfield< 3,  1> {};
        struct IDYNWK2KEN   : Bitfield< 4,  1> {};
        struct PULL_ASSIGN  : Bitfield< 7,  2> {
            enum { NONE = 0, UP = 1, DOWN = 2 };
        };
        struct PULL_STR     : Bitfield< 9, 2> {
            enum { K2 = 0, K10 = 1, K20 = 2, K40 = 3 };
        };
        struct BYPASS_FLOP  : Bitfield<11,  1> {};
        struct IHYSCTL      : Bitfield<13,  2> {};
        struct IHYSENB      : Bitfield<15,  1> {};
        struct FAST_CLK     : Bitfield<16,  1> {};
        struct SLOW_CLK     : Bitfield<17,  1> {};
        struct FILTER_SLOW  : Bitfield<18,  1> {};
        struct FILTER_EN    : Bitfield<19,  1> {};
        struct DEBOUNCE     : Bitfield<20,  1> {};
        struct STRAP_VAL    : Bitfield<23,  1> {};
        struct GD_LEVEL     : Bitfield<24,  1> {};
        struct GD_TPE       : Bitfield<25,  1> {};
        struct GD_TNE       : Bitfield<26,  1> {};
        struct DIR_IRQ_EN   : Bitfield<27,  1> {};
        struct I25COMP      : Bitfield<28,  1> {};
        struct DIS_SEC_MASK : Bitfield<29,  1> {};
        struct IODEN        : Bitfield<31,  1> {};
    };
    struct MUX  : Register<0x4, 32>{
        struct STD_MUX      : Bitfield< 0,  5> {};
        struct HGH_MUX      : Bitfield< 5,  5> {};
        struct DRD_MUX      : Bitfield<10,  5> {};
        struct CF_OD        : Bitfield<15,  1> {};
    };
    struct VAL  : Register<0x8, 32>{
        struct PAD_VAL      : Bitfield< 0,  1> {};
        struct IOUTENB      : Bitfield< 1,  1> {};
        struct IINENB       : Bitfield< 2,  1> {};
        struct FUNC_C_VAL   : Bitfield< 3, 15> {};
        struct FUNC_F_VAL   : Bitfield<18,  4> {};

        static void set(access_t *v, bool b)
        {
            PAD_VAL::set(*v, (b) ? 1 : 0);
            IOUTENB::set(*v, 0);
            IINENB::set(*v, 0);
        }
    };
    struct RVD  : Register<0xc, 32>{};

private:
    Genode::addr_t address;
    Genode::uint16_t pin;
    Genode::uint16_t offset;
public:
    Pin(Genode::addr_t, Genode::uint16_t);
    void set(bool);
};
