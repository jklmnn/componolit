package body Fw_Types
with SPARK_Mode
is

pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");

   ---------------
   -- Int_Value --
   ---------------

    pragma Assert (Int_Value (Byte'(0, 1)) = 1);
    pragma Assert (Int_Value (Byte'(1, 0)) = 16);
    pragma Assert (Int_Value (Byte'(1, 1)) = 17);

    function Exp (Base : U32; Exponent : U32) return U32
    is
        Ret : U32 := 1;
    begin
        for i in 1 .. Exponent
        loop
            Ret := Ret * Base;
        end loop;
        return Ret;
    end Exp;

    function Int_Value (Buf : Buffer) return U32
    is
        Value : U32 := 0;
    begin
        for i in 0 .. Buf'Length - 1
        loop
            Value := Value + (Int_Value (Buf (i + Buf'First)) * Exp (255, U32 (i)));
        end loop;
        return Value;
    end Int_Value;

    pragma Assert (Int_Value (Buffer'((0, 1), (0, 0), (0, 0), (0, 0))) = 1);

end Fw_Types;
