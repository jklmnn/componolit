with System;
with fw_types;
use all type fw_types.Nibble;

package fw_log is

    type Log_type is (debug, warn, error);
    subtype Arrow is String (1 .. 2);
    
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

    procedure hex_dump(value: fw_types.Buffer; dump: out String) with
        SPARK_Mode,
        Depends => (dump => (value, dump)),
        Pre => (dump'Length = 2 * value'Length);

    function hex(n: fw_types.Nibble) return Character is
        (
            if n < 10 then
                Character'Val(Integer(n) + 48)
            else
                Character'Val(Integer(n) + 87)
        )with
        SPARK_Mode,
    Depends => (hex'Result => n),
    Post => ((hex'Result in '0' .. '9') or (hex'Result in 'a' .. 'f'));

    function directed_arrow(dir: fw_types.Direction) return Arrow with
        SPARK_Mode;

end fw_log;
