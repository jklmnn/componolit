
#pragma once

#include <util/mmio.h>
#include <util/fifo.h>
#include <base/log.h>
#include <base/signal.h>
#include <timer_session/connection.h>
#include <irq_session/connection.h>
#include <util/reconstructible.h>

namespace DW {
    class I2C;
    class UnsupportedDevice : Genode::Exception {};
    enum {
        IRQ = 35,
    };
    enum I2C_C {
        TX_FIFO = 32,
        RX_FIFO = 32,
        SDA_HOLD_RX_SHIFT = 16,
        SDA_HOLD_RX_MASK = 16711680,
        CON_10BITADDR_MASTER = 0x10,
    };
    enum INTR {
        DEFAULT     = 0x254,
        RX_UNDER    = 0x001,
        RX_OVER     = 0x002,
        RX_FULL     = 0x004,
        TX_OVER     = 0x008,
        TX_EMPTY    = 0x010,
        RD_REQ      = 0x020,
        TX_ABRT    = 0x040,
        RX_DONE     = 0x080,
        ACTIVITY    = 0x100,
        STOP_DET    = 0x200,
        START_DET   = 0x400,
        GEN_CALL    = 0x800
    };
    enum ACPI { //FIXME: logged values from debian, replace with actual values read by ACPI
        SS_HCNT = 427,
        SS_LCNT = 499,
        FS_HCNT = 87,
        FS_LCNT = 159,
        SDA_HOLD = 65600
    };
    class Message;
};

class DW::Message
{
public:
    Genode::uint16_t addr;
    Genode::uint16_t flags;
    Genode::uint16_t len;
    Genode::uint8_t *buf;
    Genode::uint16_t status;

    Message(Genode::uint16_t a, Genode::uint16_t f, Genode::uint16_t l, Genode::uint8_t *b):
        addr(a), flags(f), len(l), buf(b), status(0) {}

    void dump()
    {
        Genode::log("addr: ", addr, "\nflags: ", flags, "\nlen: ", len, "\nstatus: ", status);
    }
};

class DW::I2C : Genode::Mmio
{
    /*
     * Space not used by Bitfields is reserved space and can cause undefined behaviour if it is written to.
     */
    struct CON              : Register<0x0 , 32> { // Configuration register | RW
        struct MASTER   : Bitfield<0, 1> {}; // sets master mode
        struct SPEED    : Bitfield<1, 2> {}; // sets standard or fast mode
        struct S10BADR  : Bitfield<3, 1> {}; // slave 10 bit addressing
        struct M10BADR  : Bitfield<4, 1> {}; // master 10 bit addressing
        struct RESTART  : Bitfield<5, 1> {}; // send restart conditions
        struct SLVDIS   : Bitfield<6, 1> {}; // disable slave

        enum { STANDARD = 1, FAST = 2 };

        static access_t configure(Genode::uint8_t master,
                                  Genode::uint8_t speed,
                                  Genode::uint8_t slave_10bit,
                                  Genode::uint8_t master_10bit,
                                  Genode::uint8_t restart,
                                  Genode::uint8_t slave_disable)
        {
            access_t c = 0;
            MASTER::set(c, master);
            SPEED::set(c, speed);
            S10BADR::set(c, slave_10bit);
            M10BADR::set(c, master_10bit);
            RESTART::set(c, restart);
            SLVDIS::set(c, slave_disable);
            return c;
        }
    };
    struct TAR              : Register<0x4 , 32> { // set target address | RW
        struct TARGET   : Bitfield< 0, 10> {}; // target address
        struct GCORST   : Bitfield<10, 1> {}; //general call or start byte
        struct SPECIAL  : Bitfield<11, 1> {}; //if set, perform as defined in GCORST
        struct M10BADR  : Bitfield<12, 1> {}; //start transfers in 7 or 10 bit mode
    };
    struct SAR              : Register<0x8 , 32> { // holds address if in slave mode | RW # not used here
        struct ADDR     : Bitfield<0, 10> {};
    };
    struct HS_MADDR         : Register<0xc, 32> { //High speed mode code | RO
        struct HS_MAR   : Bitfield<0, 3> {}; // High speed mode master code
    };
    struct DATA_CMD         : Register<0x10, 32> { // write to TX and read from RX | RW
        struct DATA     : Bitfield< 0, 8> {}; // data to be written or read from/to I2C
        struct CMD      : Bitfield< 8, 1> {}; // 0 for write and 1 for read
        struct STOP     : Bitfield< 9, 1> {}; // STOP the transmit even if TX fifo is not empty
        struct RESTART  : Bitfield<10, 1> {}; // force a RESTART

        static access_t stopping_write(access_t cmd, access_t data, bool stop){
            access_t v = 0;
            CMD::set(v, cmd);
            DATA::set(v, data);
            STOP::set(v, (access_t)stop);
            return v;
        }
    };
    struct SS_SCL_HCNT      : Register<0x14, 32> { // SCL clock high period count for standard speed | RW
        struct SSHCNT   : Bitfield <0, 16> {};
    };
    struct SS_SCL_LCNT      : Register<0x18, 32> { // SCL clock low period count for standard speed | RW
        struct SSLCNT   : Bitfield <0, 16> {};
    };
    struct FS_SCL_HCNT      : Register<0x1c, 32> { // SCL clock high period count for fast speed | RW
        struct FSHCNT   : Bitfield <0, 16> {};
    };
    struct FS_SCL_LCNT      : Register<0x20, 32> { // SCL clock low period count for fast speed | RW
        struct FSLCNT   : Bitfield <0, 16> {};
    };
    struct HS_SCL_HCNT      : Register<0x24, 32> { // SCL clock high period count for high speed | RW
        struct HSHCNT   : Bitfield <0, 16> {};
    };
    struct HS_SCL_LCNT      : Register<0x28, 16> { // SCL clock low period count for high speed | RW
        struct HSLCNT   : Bitfield <0, 16> {};
    };
    struct INTR_STAT        : Register<0x2c, 32> { // mask bits for interrupt mask register, cleared by reading the matching interrupt clear register | RO
        struct RXUNDER  : Bitfield < 0, 1> {}; // Set if the processor tries to read from an empty RX buffer
        struct RXOVER   : Bitfield < 1, 1> {}; // Set if the RX buffer is full and an additional byte is received
        struct RXFULL   : Bitfield < 2, 1> {}; // Set if the RX buffer reaches or goes above the RX threshold
        struct TXOVER   : Bitfield < 3, 1> {}; // Set if the TX buffer is filled and the processor tries to write another byte
        struct TXEMPTY  : Bitfield < 4, 1> {}; // Set if the TX buffer is at or below the TX threshold
        struct RDREQ    : Bitfield < 5, 1> {}; // Set if acting as a slave and another master tries to read
        struct TXABRT   : Bitfield < 6, 1> {}; // Set if I2C transmitter is unable to complete actions on transmit fifo
        struct RXDONE   : Bitfield < 7, 1> {}; // Set in slave mode and if master does not ack a byte (EOT)
        struct ACTIVITY : Bitfield < 8, 1> {}; // Set if activity is existent
        struct STOPDET  : Bitfield < 9, 1> {}; // Set if a STOP has occured
        struct STARTDET : Bitfield <10, 1> {}; // Set if a START or RESTART has occured
        struct GENCALL  : Bitfield <11, 1> {}; // Set if a general call address is received and acked
    };
    struct INTR_MASK        : Register<0x30, 32> { // mask the corresponding interrut status bits | RW
        struct RXUNDER  : Bitfield < 0, 1> {}; // Set if the processor tries to read from an empty RX buffer
        struct RXOVER   : Bitfield < 1, 1> {}; // Set if the RX buffer is full and an additional byte is received
        struct RXFULL   : Bitfield < 2, 1> {}; // Set if the RX buffer reaches or goes above the RX threshold
        struct TXOVER   : Bitfield < 3, 1> {}; // Set if the TX buffer is filled and the processor tries to write another byte
        struct TXEMPTY  : Bitfield < 4, 1> {}; // Set if the TX buffer is at or below the TX threshold
        struct RDREQ    : Bitfield < 5, 1> {}; // Set if acting as a slave and another master tries to read
        struct TXABRT   : Bitfield < 6, 1> {}; // Set if I2C transmitter is unable to complete actions on transmit fifo
        struct RXDONE   : Bitfield < 7, 1> {}; // Set in slave mode and if master does not ack a byte (EOT)
        struct ACTIVITY : Bitfield < 8, 1> {}; // Set if activity is existent
        struct STOPDET  : Bitfield < 9, 1> {}; // Set if a STOP has occured
        struct STARTDET : Bitfield <10, 1> {}; // Set if a START or RESTART has occured
        struct GENCALL  : Bitfield <11, 1> {}; // Set if a general call address is received and acked
    };
    struct RAW_INTR_STAT    : Register<0x34, 32> { // Contains the real unmasked status bits | RO
        struct RXUNDER  : Bitfield < 0, 1> {}; // Set if the processor tries to read from an empty RX buffer
        struct RXOVER   : Bitfield < 1, 1> {}; // Set if the RX buffer is full and an additional byte is received
        struct RXFULL   : Bitfield < 2, 1> {}; // Set if the RX buffer reaches or goes above the RX threshold
        struct TXOVER   : Bitfield < 3, 1> {}; // Set if the TX buffer is filled and the processor tries to write another byte
        struct TXEMPTY  : Bitfield < 4, 1> {}; // Set if the TX buffer is at or below the TX threshold
        struct RDREQ    : Bitfield < 5, 1> {}; // Set if acting as a slave and another master tries to read
        struct TXABRT   : Bitfield < 6, 1> {}; // Set if I2C transmitter is unable to complete actions on transmit fifo
        struct RXDONE   : Bitfield < 7, 1> {}; // Set in slave mode and if master does not ack a byte (EOT)
        struct ACTIVITY : Bitfield < 8, 1> {}; // Set if activity is existent
        struct STOPDET  : Bitfield < 9, 1> {}; // Set if a STOP has occured
        struct STARTDET : Bitfield <10, 1> {}; // Set if a START or RESTART has occured
        struct GENCALL  : Bitfield <11, 1> {}; // Set if a general call address is received and acked
    };
    struct RX_TL            : Register<0x38, 32> { // RX fifo threshold | RW
        struct RXTL     : Bitfield <0, 8> {};
    };
    struct TX_TL            : Register<0x3c, 32> { // TX fifo threshold | RW
        struct TXTL     : Bitfield <0, 8> {};
    };
    struct CLR_INTR         : Register<0x40, 32> { // Read to clear all interrupt registers | RO
        struct INTR     : Bitfield <0, 1> {};
    };
    struct CLR_RX_UNDER     : Register<0x44, 32> { // Read to clear RXUNDER of RAW_INTR_STAT | RO
        struct RXUNDER  : Bitfield <0, 1> {};
    };
    struct CLR_RX_OVER      : Register<0x48, 32> { // Read to clear RXOVER of RAW_INTR_STAT | RO
        struct RXOVER   : Bitfield <0, 1> {};
    };
    struct CLR_TX_OVER      : Register<0x4c, 32> { // Read to clear TXOVER of RAW_INTR_STAT | RO
        struct TXOVER   : Bitfield <0, 1> {};
    };
    struct CLR_RD_REQ       : Register<0x50, 32> { // Read to clear RDREQ of RAW_INTR_STAT | RO
        struct RDREQ    : Bitfield <0, 1> {};
    };
    struct CLR_TX_ABRT      : Register<0x54, 32> { // Read to clear TXABRT of RAW_INTR_STAT | RO
        struct TXABRT   : Bitfield <0, 1> {};
    };
    struct CLR_RX_DONE      : Register<0x58, 32> { // Read to clear RXDONE of RAW_INTR_STAT | RO
        struct RXDONE   : Bitfield <0, 1> {};
    };
    struct CLR_ACTIVITY     : Register<0x5c, 32> { // Read to clear ACTIVITY of RAW_INTR_STAT | RO
        struct ACTIVITY : Bitfield <0, 1> {};
    };
    struct CLR_STOP_DET     : Register<0x60, 32> { // Read to clear STOPDET of RAW_INTR_STAT | RO
        struct STOPDET  : Bitfield <0, 1> {};
    };
    struct CLR_START_DET    : Register<0x64, 32> { // Read to clear STARTDET of RAW_INTR_STAT | RO
        struct STARTDET : Bitfield <0, 1> {};
    };
    struct CLR_GEN_CALL     : Register<0x68, 32> { // Read to clear GENCALL of RAW_INTR_STAT | RO
        struct GENCALL  : Bitfield <0, 1> {};
    };
    struct IC_ENABLE           : Register<0x6c, 32> { // Enable and disable I2C operation | RW
        struct ENABLE   : Bitfield <0, 1> {}; // Enable or disable I2C
        struct TXABORT  : Bitfield <0, 1> {}; // Write to triggers a TX abort
    };
    struct STATUS           : Register<0x70, 32> { // Indicate current transfer and fifo status | RO
        struct ACTIVITY : Bitfield <0, 1> {}; // I2C activity
        struct TFNF     : Bitfield <1, 1> {}; // TX fifo NOT full
        struct TFE      : Bitfield <2, 1> {}; // TX fifo empty
        struct RFNE     : Bitfield <3, 1> {}; // RX fifo NOT empty
        struct RFF      : Bitfield <4, 1> {}; // RX fifo full
        struct MSTACT   : Bitfield <5, 1> {}; // Set if Master Finite State Machine (FSM) is not in IDLE
        struct SLVACT   : Bitfield <6, 1> {}; // Set if Slave Finite State Machine is not in IDLE

        static bool busy(access_t s)
        {
            return (bool)ACTIVITY::get(s);
        }
    };
    struct TX_FLR            : Register<0x74, 32> { // Number of valid data entries in TX fifo | RO
        struct TXFLR    : Bitfield <0, 7> {};
    };
    struct RX_FLR            : Register<0x78, 32> { // Number of valid data entries in RX fifo | RO
        struct RXFLR    : Bitfield <0, 7> {};
    };
    struct SDA_HOLD         : Register<0x7c, 32> { // Amount of time delay (number of l4_sp_clk periods) for the falling edge of SCL
        struct SDAHOLD  : Bitfield <0, 16> {};
    };
    struct TX_ABRT_SOURCE   : Register<0x80, 32> { // Indicates the source of a TX_ABRT | RW
        struct NA7BADR  : Bitfield < 0, 1> {}; // 7 bit address mode, sent adress was not acked by a slave
        struct NA10BA1  : Bitfield < 1, 1> {}; // 10 bit address mode, first address byte was not acked by a slave
        struct NA10BA2  : Bitfield < 2, 1> {}; // 10 bit address mode, second address byte was not acked by a slave
        struct NATXD    : Bitfield < 3, 1> {}; // No ack recved for sent data byte
        struct NAGCALL  : Bitfield < 4, 1> {}; // No ack for general call
        struct RDGCALL  : Bitfield < 5, 1> {}; // General call sent but next byte should be read
        struct HSADET   : Bitfield < 6, 1> {}; // High speed Master code was acked
        struct SBTADET  : Bitfield < 7, 1> {}; // Sent START byte was acked
        struct HSNRS    : Bitfield < 8, 1> {}; // RESTART is disabled and transferin high speed mode tried
        struct SBTNRS   : Bitfield < 9, 1> {}; // RESTART is disabled but START was sent, needs to be fixed to be resetted
        struct RD10BNRS : Bitfield <10, 1> {}; // RESTART is disabled and master sends 10 bit mode read command
        struct MSTDIS   : Bitfield <11, 1> {}; // Init master operation with master mode disabled
        struct ARBLST   : Bitfield <12, 1> {}; // Master has lost arbitration
        struct SLVFLTXF : Bitfield <13, 1> {}; // Slave received read command, but TX fifo is not empty and gets aborted and flushed
        struct SLVARBLT : Bitfield <14, 1> {}; // Slave lost bus while transmitting data to remote master
        struct SLVRDTX  : Bitfield <15, 1> {}; // Processor responds to slave mode req to transmit data and CMD[8] = 1 is written
    };
    struct SLV_DATA_NACK    : Register<0x84, 32> { // Generate NACK for data when slave recv | RW # not used here, omitted _ONLY in register name
        struct NACK     : Bitfield <0, 1> {};
    };
    struct DMA_CR           : Register<0x88, 32> { // Enable DMA controller interface operation | RW # not used here
        struct RDMAE    : Bitfield <0, 1> {}; // Enable/disable recv DMA
        struct TDMAE    : Bitfield <1, 1> {}; // Enable/disable transmit DMA
    };
    struct DMA_TDLR         : Register<0x8c, 32> { // DMA transmit operation | RW # not used here
        struct DMATDL   : Bitfield <0, 6> {}; // Level at which DMA request is made by transmit logic
    };
    struct DMR_RDLR         : Register<0x90, 32> { // DMA receive operation | RW # not used here
        struct DMARDL   : Bitfield <0, 6> {}; // Level at which DMA request is made by receive logic
    };
    struct SDA_SETUP        : Register<0x94, 32> { // Amount of time delay for the rising edge of SCL | RW # not used here
        struct SDASETUP : Bitfield <0, 8> {};
    };
    struct ACK_GENERAL_CALL : Register<0x98, 32> { // Controls to respond with ACK or NACK to general call address | RW # not used here
        struct AGENCALL : Bitfield <0, 1> {}; // Set ACK for 1 and NACK for 0
    };
    struct ENABLE_STATUS    : Register<0x9c, 32> { // Report I2C hardware status | RO
        struct ICEN     : Bitfield <0, 1> {}; // Value on output port ic_en
        struct SLVDWB   : Bitfield <1, 1> {}; // Indicates if slave operation has been aborted by setting enable to 0
        struct SLVRXDL  : Bitfield <2, 1> {}; // Indicates if min 1 data byte was lost by setting enable to 0

        static bool is_enabled(access_t v)
        {
            return (bool)ICEN::get(v);
        }
    };
    struct FS_SPKLEN        : Register<0xa0, 32> { // Duration of longest filtered spike when in SS or FS | RW # not used here
        struct SPKLEN   : Bitfield <0, 8> {};     
    };
    struct HS_SPKLEN        : Register<0xa4, 32> { // Duration of longest filtered spike when in HS | RW
        struct SPKLEN   : Bitfield <0, 8> {};
    };
    struct COMP_PARAM_1     : Register<0xf4, 32> { // Contains encoded information about parameter settngs | RO
        struct APBDATW  : Bitfield < 0, 2> {}; // APB data width
        struct MAXSPEED : Bitfield < 2, 2> {}; // Max speed mode
        struct CNTVAL   : Bitfield < 4, 1> {}; // Maxes *CNT registeres readable/writable
        struct INTRIO   : Bitfield < 5, 1> {}; // All interrupt sources combined to single output
        struct HASDMA   : Bitfield < 6, 1> {}; // DMA available
        struct ADENCPM  : Bitfield < 7, 1> {}; // Added encoded parameters
        struct RXBDEP   : Bitfield < 8, 8> {}; // RX fifo depth
        struct TXBDEP   : Bitfield <16, 8> {}; // TX fifo depth
    };
    struct COMP_VERSION     : Register<0xf8, 32> { // I2C Version | RO
        enum { MIN_VERS = 0x3131312a };

        static void get_string(char vstr[], access_t version)
        {
            for(Genode::size_t i = 0; i < 4; ++i){
                vstr[6 - 2 * i] = (version >> 8 * i) & 0xff;
                vstr[2 * i + 1] = '.';
            }
            vstr[7] = '\0';
        }
    };
    struct COMP_TYPE        : Register<0xfc, 32> { // I2C component type | RO
        enum { DEFAULT = 0x44570140, SWAB = 0x40015744, HALF = 0x00000140 };
    };
    struct CLOCK_PARAMS     : Register<0x800, 32> { // Indicate if 100 or 133MHz are used
        struct HSSRCCLK : Bitfield <0, 1> {}; // 0 - 100MHz, 1 - 133MHz
    };
    struct RESETS           : Register<0x804, 32> { // Software reset
        struct RSTAPB   : Bitfield <0, 1> {};
        struct RSTFUNC  : Bitfield <1, 1> {};
    };
    struct GENERAL          : Register<0x808, 32> { // General purpose register
        struct TXLSTBT  : Bitfield <4, 1> {}; // Software indicates last byte for TX
        struct FXDIS609 : Bitfield <5, 1> {}; // Bit for fix for NACK bug (HSD 374609)
        struct FXDIS798 : Bitfield <6, 1> {}; // Bit for fix for NACK bug (HSD 374798)
        struct FIX1699  : Bitfield <7, 1> {}; // Enable fix 9000481699
        struct FIX0770  : Bitfield <8, 1> {}; // Enable fix 9000530770
        struct FIX1680  : Bitfield <9, 1> {}; // Enable fix 9000521680
    };
    struct ACK_COUNT        : Register<0x818, 32> { // TX transaction counter
        struct TXACKCNT : Bitfield < 0, 16> {}; // TX transaction count
        struct TXCNTOV  : Bitfield <16,  1> {}; // Indicate overflow
        struct CLRTXOV  : Bitfield <19,  1> {}; // Clear TX transaction counter
    };
    struct TX_COMPLETE_INTR : Register<0x820, 32> { // TX transaction has finished interrupt
        struct TXCINT   : Bitfield <0, 1> {}; // TX transaction has finished
        struct TXCMASK  : Bitfield <1, 1> {}; // Mask TX transaction has finished interrupt
    };
    struct TX_COMPLETE_CLR  : Register<0x824, 32> { // write 1 to clear TX_COMPLETE interupt
        struct TXCICLR  : Bitfield <0, 1> {};
    };
private:
    Timer::Connection timer;
    Genode::Fifo<Genode::Fifo_element<DW::Message>> message_queue;
    Genode::Irq_connection _irq;
    Genode::Constructible<Genode::Signal_handler<DW::I2C>> sigh;
    int busy_wait();
    void ic_enable_wait(bool);
    void init_device();
    void _rx();
    void _init_tx();
    void _tx();
public:
    I2C(Genode::addr_t, Genode::uint32_t, Genode::Env&, Genode::addr_t = 0, Genode::size_t = 0);
    void _stat();
    inline void handle_irq(){
        _stat();
    }
    void send(Genode::Fifo_element<DW::Message>*);
};

