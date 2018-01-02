with System;
with Fw_Types;
use all type Fw_Types.Nibble;

package Fw_Log is

    type Log_Type is (Debug, Warn, Error);
    subtype Arrow is String (1 .. 2);

    procedure C_Log (Msg : System.Address)
    with
        Import,
        Convention => C,
        External_Name => "log";

    procedure C_Warn (Msg : System.Address)
    with
        Import,
        Convention => C,
        External_Name => "warn";

    procedure C_Error (Msg : System.Address)
    with
        Import,
        Convention => C,
        External_Name => "error";

    procedure Log_Int (Num : Fw_Types.U32)
    with
        Import,
        Convention => C,
        External_Name => "log_int";

    procedure Log (Msg : String;
                   T   : Log_Type := Debug)
    with
        SPARK_Mode,
        Pre => Msg'Length < 1024;

    procedure Hex_Dump (Value :        Fw_Types.Buffer;
                        Dump  :    out String)
    with
        SPARK_Mode,
        Depends => (Dump => (Value, Dump)),
        Pre     => (Dump'Length = 2 * Value'Length);

    function Hex (Nibble : Fw_Types.Nibble) return Character
    is
        (
            if Nibble < 10 then
                Character'Val (Integer (Nibble) + 48)
            else
                Character'Val (Integer (Nibble) + 87)
        )
    with
        SPARK_Mode,
        Depends => (Hex'Result => Nibble),
        Post    => ((Hex'Result in '0' .. '9') or (Hex'Result in 'a' .. 'f'));

    function Directed_Arrow (Dir : Fw_Types.Direction) return Arrow
    with
        SPARK_Mode;

end Fw_Log;
