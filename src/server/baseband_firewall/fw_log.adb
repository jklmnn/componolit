package body Fw_Log
is

pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");

    function Directed_Arrow (Dir : Fw_Types.Direction) return Arrow
    is
        (case Dir is
            when Fw_Types.Unknown => "--",
            when Fw_Types.AP      => "=>",
            when Fw_Types.BP      => "<=");

end Fw_Log;
