package body Fw_Log
is

pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");

    procedure Log (Msg : String; T : Log_Type := Debug)
    is
    begin
        case T is
            when Debug => Genode_Log.Log (Msg);
            when Warn  => Genode_Log.Warn (Msg);
            when Error => Genode_Log.Error (Msg);
        end case;
    end Log;

    procedure Hex_Dump (Value :        Fw_Types.Buffer;
                        Dump  :    out String)
    is
        v : Fw_Types.Byte;
    begin
        Dump := (others => '~');
        for i in 0 .. Value'Length - 1
        loop
            v := Value (Value'First + i);
            Dump (Dump'First + i * 2)     := Hex (v and 16#0f#);
            Dump (Dump'First + i * 2 + 1) := Hex ((v and 16#f0#) / 16);
        end loop;
    end Hex_Dump;

    function Directed_Arrow (Dir : Fw_Types.Direction) return Arrow
    is
        (case Dir is
            when Fw_Types.Unknown => "--",
            when Fw_Types.AP      => "=>",
            when Fw_Types.BP      => "<=");

end Fw_Log;
