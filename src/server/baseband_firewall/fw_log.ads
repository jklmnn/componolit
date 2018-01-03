with Fw_Types;
use all type Fw_Types.Byte;

package Fw_Log
is
    subtype Arrow is String (1 .. 2);

    procedure Hex_Dump (Value :        Fw_Types.Buffer;
                        Dump  :    out String)
    with
        Depends => (Dump => (Value, Dump)),
        Pre     => (Dump'Length = 2 * Value'Length);

    function Hex (Value : Fw_Types.Byte) return Character
    is
        (
            if Value < 10 then
                Character'Val (Integer (Value) + 48)
            else
                Character'Val (Integer (Value) + 87)
        )
    with
        Pre     => Value <= 16#f#,
        Depends => (Hex'Result => Value),
        Post    => ((Hex'Result in '0' .. '9') or (Hex'Result in 'a' .. 'f'));

    function Directed_Arrow (Dir : Fw_Types.Direction) return Arrow;
end Fw_Log;
