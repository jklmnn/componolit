package body Fw_Types
is

pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");

   ---------------
   -- Int_Value --
   ---------------

    function Exp (Base : U32; Exponent : U32) return U32
    is
        Ret : U32 := 1;
    begin
        for i in 1 .. Exponent
        loop
            Ret := Ret * Base;
            --  pragma Loop_Invariant (Ret = Base ** Natural (i));
        end loop;
        return Ret;
    end Exp;

end Fw_Types;
