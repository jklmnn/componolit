
#include <i2c_designware.h>

using namespace DW;

I2C::I2C(Genode::Env &env, GSL::i2c_desc *desc) :
    Genode::Attached_io_mem_dataspace(env, desc->base, desc->length, true),
    Genode::Mmio((Genode::addr_t)local_addr<Genode::addr_t>()),
    timer(env),
    _irq(env, desc->irq)
{
    sigh.construct(env.ep(), *this, &I2C::handle_irq);
    _irq.sigh(*sigh);
    Genode::log("Initializing I2C driver.");
    if(COMP_TYPE::DEFAULT != read<COMP_TYPE>())
        throw UnsupportedDevice();
    Genode::log("Params: ", read<COMP_PARAM_1>());
    init_device();
    Genode::log("I2C driver initialized.");
    _irq.ack_irq();
}

int I2C::busy_wait()
{
    int timeout = 100;
    while(timeout--){
        STATUS::access_t s = read<STATUS>();
        if(!STATUS::busy(s))
            return 0;
        timer.usleep(1000);
    }
    return 1;
}

void I2C::ic_enable_wait(bool en)
{
    write<IC_ENABLE>(en);
    int timeout = 100;
    while(timeout--){
        ENABLE_STATUS::access_t es = read<ENABLE_STATUS>();
        if(ENABLE_STATUS::is_enabled(es) == en)
            return;
        timer.usleep(250);
    }
    Genode::warning("Enabling device timed out");
}

void I2C::init_device()
{
    Genode::log("Initializing I2C controller.");
    ic_enable_wait(false);

    write<SS_SCL_HCNT>(ACPI::SS_HCNT);
    write<SS_SCL_LCNT>(ACPI::SS_LCNT);
    write<FS_SCL_HCNT>(ACPI::FS_HCNT);
    write<FS_SCL_LCNT>(ACPI::FS_LCNT);
   
    COMP_VERSION::access_t version = read<COMP_VERSION>();
    char vbuf[8];
    COMP_VERSION::get_string(vbuf, version);
    Genode::String<8> vstr = Genode::String<8>(vbuf);
    Genode::log("I2C Version ", vstr);

    Genode::uint32_t sda_hold = read<SDA_HOLD>();
    if(!(sda_hold & I2C_C::SDA_HOLD_RX_MASK))
        sda_hold |= 1 << I2C_C::SDA_HOLD_RX_SHIFT;
    write<SDA_HOLD>(sda_hold);

    write<TX_TL>(I2C_C::TX_FIFO / 2);
    write<RX_TL>(0);

    CON::access_t config = CON::configure(1, CON::STANDARD, 0, 0, 1, 1);
    write<CON>(config);
    Genode::log("Config: ", config);

    write<INTR_MASK>(0);
}

void I2C::send(Genode::Fifo_element<Message> *msg)
{
    message_queue.enqueue(msg);

    if(!read<IC_ENABLE>())
        _init_tx();
}

void I2C::_init_tx()
{
    busy_wait();

    Genode::uint16_t addr = message_queue.head()->object()->addr;
    Genode::log("Initializing message");
    ic_enable_wait(false); 
    write<CON::M10BADR>(0);

    write<TAR>(addr);

    write<INTR_MASK>(0);

    ic_enable_wait(true);

    read<CLR_INTR>();
    write<INTR_MASK>(INTR::DEFAULT);
}

void I2C::_stat()
{
    Genode::log("handling i2c irq");

    bool enable = read<IC_ENABLE>();
    RAW_INTR_STAT::access_t stat = read<RAW_INTR_STAT>();
    IC_ENABLE::access_t en_reg = read<IC_ENABLE>();

    if(!en_reg || !(stat & ~INTR::ACTIVITY)){
        Genode::log("Device disabled");
        return;
    }

    stat = read<INTR_STAT>();

    if (stat & INTR::RX_UNDER){
        Genode::log("RX_UNDER");
        read<CLR_RX_UNDER>();
    }
    if (stat & INTR::RX_OVER){
        Genode::log("RX_OVER");
        read<CLR_RX_OVER>();
    }
    if (stat & INTR::TX_OVER){
        Genode::log("TX_OVER");
        read<CLR_TX_OVER>();
    }
    if (stat & INTR::RD_REQ){
        Genode::log("RD_REQ");
        read<CLR_RD_REQ>();
    }
    if (stat & INTR::TX_ABRT) {
        //FIXME: Preserve TX_ABRT_SOURCE first
        Genode::log("TX_ABRT_SOURCE ", read<CLR_TX_ABRT>());
    }
    if (stat & INTR::RX_DONE){
        Genode::log("RX_DONE");
        read<CLR_RX_DONE>();
    }
    if (stat & INTR::ACTIVITY){
        Genode::log("ACTIVITY");
        read<CLR_ACTIVITY>();
    }
    if (stat & INTR::STOP_DET){
        Genode::log("STOP_DET");
        read<CLR_STOP_DET>();
    }
    if (stat & INTR::START_DET){
        Genode::log("START_DET");
        read<CLR_START_DET>();
    }
    if (stat & INTR::GEN_CALL){
        Genode::log("GEN_CALL");
        read<CLR_GEN_CALL>();
    }

    if (stat & INTR::TX_ABRT){
        write<INTR_MASK>(0);
    }

    if (stat & INTR::RX_FULL){
        //TODO: read buffer
        Genode::log("RX");
    }

    if (stat & INTR::TX_EMPTY){
        //TODO; write msg to buffer
        Genode::log("TX");
        _tx();
    }
}

void I2C::_tx()
{
    Genode::log("Sending message...");
    Message msg = *message_queue.head()->object();
    Genode::uint16_t addr = msg.addr;
    if(!message_queue.empty()){
        Genode::uint32_t tx_limit = I2C_C::TX_FIFO - read<TX_FLR>();
        Genode::uint32_t rx_limit = I2C_C::RX_FIFO - read<RX_FLR>();
        for(;tx_limit > 0 && msg.status < msg.len; --tx_limit, ++msg.status){
            Genode::uint8_t byte = msg.buf[msg.status];
            DATA_CMD::access_t d = DATA_CMD::stopping_write(0, byte, (msg.len - msg.status == 1));
            write<DATA_CMD>(d);
        }
        message_queue.dequeue()->object()->dump();
        write<INTR_MASK>(0x244);
    }
    write<IC_ENABLE>(0);
    //TODO callback
    _irq.ack_irq();
    if(!message_queue.empty())
        _init_tx();
}
