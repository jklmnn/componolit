with System;
with Fw_Types;

package body Genode_Log
with
    SPARK_Mode => Off
is

pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");

    procedure Log (Msg : String)
    is
        procedure C_Log (Arg : System.Address)
        with
            Import,
            Convention => C,
            External_Name => "log";

        C_Msg : String := Msg & Character'Val (0);
    begin
        C_Log (C_Msg'Address);
    end Log;

    procedure Warn (Msg : String)
    is
        procedure C_Warn (Arg : System.Address)
        with
            Import,
            Convention => C,
            External_Name => "warn";

        C_Msg : String := Msg & Character'Val (0);
    begin
        C_Warn (C_Msg'Address);
    end Warn;

    procedure Error (Msg : String)
    is
        procedure C_Error (Arg : System.Address)
        with
            Import,
            Convention => C,
            External_Name => "error";

        C_Msg : String := Msg & Character'Val (0);
    begin
        C_Error (C_Msg'Address);
    end Error;

    procedure Int (Num : Integer)
    is
        procedure C_Int (Arg : Fw_Types.U32)
        with
            Import,
            Convention => C,
            External_Name => "log_int";
    begin
        C_Int (Fw_Types.U32 (Num));
    end Int;

end Genode_Log;
