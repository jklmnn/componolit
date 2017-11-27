with System;

package baseband_fw is

    procedure filter(
        dest: System.Address;
        src: System.Address;
        dest_size: Integer;
        src_size: Integer
        );

    private

    type Nibble is mod 16;
    for Nibble'Size use 4;

    type Byte is record
        lower: Nibble;
        upper: Nibble;
    end record;
    
    for Byte use 
        record
            lower at 0 range 0 .. 3;
            upper at 0 range 4 .. 7;
        end record;
    for Byte'Size use 8;

    type Buffer is array (integer range <>) of Byte;
    type Log_type is (debug, warn, error);
    subtype Mac is Buffer(0 .. 5);

    type Eth is record
        source : Mac;
        destination : Mac;
        size : Buffer(0 .. 1);
    end record;

    type packet is record
        eth_header: Eth;
   --     ip_header: IP;
   --     udp_header: UDP;
   --     ril_packet: RIL;
    end record;

    procedure c_log(msg: System.Address) with
        Import,
        Convention => C,
        External_name => "log";

    procedure c_warn(msg: System.Address) with
        Import,
        Convention => C,
        External_name => "warn";

    procedure c_error(msg: System.Address) with
        Import,
        Convention => C,
        External_name => "error";

    procedure log_int(num: Integer) with
        Import,
        Convention => C,
        External_name => "log_int";

    procedure log(msg: String; t: log_type) with
        SPARK_Mode,
        Pre => msg'Length < 1024;

    procedure hex_dump(value: Buffer; dump: out String) with
        SPARK_Mode,
        Depends => (dump => (value, dump)),
        Pre => (dump'Length = 2 * value'Length);

    function hex(n: Nibble) return Character is
        (
            if n < 10 then
                Character'Val(Integer(n) + 48)
            else
                Character'Val(Integer(n) + 87)
        )with
        SPARK_Mode,
    Depends => (hex'Result => n),
    Post => ((hex'Result in '0' .. '9') or (hex'Result in 'a' .. 'f'));

    procedure filter_spark (
        dest: out Buffer;
        src: in Buffer) with
        SPARK_Mode,
        Pre => (dest'Length = src'Length),
        Depends => (dest => src);

end baseband_fw;
