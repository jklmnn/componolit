package body Fw_Types
is

    pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");

    ---------------
    -- Int_Value --
    ---------------

    function Exp (Base : U32; Exponent : U32) return U64
    is
        Ret : U64 := 1;
    begin
        for i in 1 .. Exponent
        loop
            Ret := Ret * U64 (Base);
            --  pragma Loop_Invariant (Ret = U64 (Base ** Natural (i)));
        end loop;
        return Ret;
    end Exp;

    function Image (Val : U08) return H08
    is
        Hx : H08 := H08'(others => '~');
    begin
        Hx (Hx'First)     := Hex ((Val and 16#f0#) / 16);
        Hx (Hx'First + 1) := Hex (Val and 16#0f#);
        return Hx;
    end Image;

    function Image (Val : U16) return H16
    is
        Hx : H16 := H16'(others => '~');
        v : U08 := U08 ((Val and 16#ff00#) / 256);
    begin
        Hx (Hx'First .. Hx'First + 1) := Image (v);
        v := U08 (Val and 16#00ff#);
        Hx (Hx'First + 2 .. Hx'First + 3) := Image (v);
        return Hx;
    end Image;

    function Image (Val : U32) return H32
    is
        Hx : H32 := H32'(others => '~');
        v : U16 := U16 ((Val and 16#ffff0000#) / 65536);
    begin
        Hx (Hx'First .. Hx'First + 3) := Image (v);
        v := U16 (Val and 16#0000ffff#);
        Hx (Hx'First + 4 .. Hx'First + 7) := Image (v);
        return Hx;
    end Image;

end Fw_Types;
