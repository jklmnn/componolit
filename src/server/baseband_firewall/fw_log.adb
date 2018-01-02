package body Fw_Log
is
    procedure Log (Msg : String; T : Log_Type := Debug)
    is
        C_Msg : String := Msg & Character'Val (0);
    begin
        pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");
        case T is
            when Debug => C_Log (C_Msg'Address);
            when Warn  => C_Warn (C_Msg'Address);
            when Error => C_Error (C_Msg'Address);
        end case;
    end Log;

    procedure Hex_Dump (Value :        Fw_Types.Buffer;
                        Dump  :    out String)
        with SPARK_Mode
    is
    begin
        Dump := (others => '~');
        for i in 0 .. Value'Length - 1
        loop
            Dump (Dump'First + i * 2) := Hex (Value (Value'First + i).Lower);
            Dump (Dump'First + i * 2 + 1) := Hex (Value (Value'First + i).Upper);
        end loop;
    end Hex_Dump;

    function Directed_Arrow (Dir : Fw_Types.Direction) return Arrow
    is
        (case Dir is
            when Fw_Types.Unknown => "--",
            when Fw_Types.AP      => "=>",
            when Fw_Types.BP      => "<=")
        with SPARK_Mode;

end Fw_Log;
