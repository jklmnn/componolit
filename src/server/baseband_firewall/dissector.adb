pragma Ada_2012;

package body Dissector
with
SPARK_Mode
is

    pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");

    function UXX_Be (buffer : Fw_Types.Buffer)
                     return UXX
    is
        value : UXX := 0;
    begin
        for i in Fw_Types.U32 range 0 .. (UXX'Size / 8) - 1 loop
            pragma Loop_Invariant (buffer'Length > (UXX'Size / 8) - 1);
            value := value + UXX (buffer (buffer'Last - Fw_Types.U32 (i))) * UXX (Fw_Types.Exp (256, i));
        end loop;
        return value;
    end UXX_Be;

    function U16_Be is new UXX_Be (Fw_Types.U16);
    function U32_Be is new UXX_Be (Fw_Types.U32);
    function U64_Be is new UXX_Be (Fw_Types.U64);

    ------------
    -- Eth_Be --
    ------------

    function Eth_Be
      (buffer : Fw_Types.Buffer)
       return Fw_Types.Eth
    is
        header : Fw_Types.Eth;
        ethtype : Fw_Types.Buffer (0 .. 1) := (0, 0);
    begin
        ethtype (0) := buffer (buffer'First + 12);
        ethtype (1) := buffer (buffer'First + 13);

        pragma Assert (buffer'First + 13 <= buffer'Last);
        header.Destination.OUI_0 := buffer (buffer'First + 0);
        header.Destination.OUI_1 := buffer (buffer'First + 1);
        header.Destination.OUI_2 := buffer (buffer'First + 2);
        header.Destination.NIC_0 := buffer (buffer'First + 3);
        header.Destination.NIC_1 := buffer (buffer'First + 4);
        header.Destination.NIC_2 := buffer (buffer'First + 5);

        header.Source.OUI_0 := buffer (buffer'First + 6);
        header.Source.OUI_1 := buffer (buffer'First + 7);
        header.Source.OUI_2 := buffer (buffer'First + 8);
        header.Source.NIC_0 := buffer (buffer'First + 9);
        header.Source.NIC_1 := buffer (buffer'First + 10);
        header.Source.NIC_2 := buffer (buffer'First + 11);

        pragma Assert (Fw_Types.U16'Size / 8 = 2);
        pragma Assert (ethtype'Length = 2);
        header.Ethtype := U16_Be (ethtype);

        return header;
    end Eth_Be;

    -------------
    -- Sl3p_Be --
    -------------

    function Sl3p_Be
      (buffer : Fw_Types.Buffer)
       return Fw_Types.Sl3p
    is
        header : Fw_Types.Sl3p;
    begin
        header.Sequence_number := U64_Be (buffer (buffer'First .. buffer'First + 7));
        header.Length := U32_Be (buffer (buffer'First + 8 .. buffer'First + 11));
        return header;
    end Sl3p_Be;

    ------------
    -- Ril_Be --
    ------------

    function Ril_Be
      (buffer : Fw_Types.Buffer)
       return Fw_Types.RIL
    is
        header : Fw_Types.RIL;
    begin
        header.Length := U32_Be (buffer (buffer'First .. buffer'First + 3));
        header.ID := U32_Be (buffer (buffer'First + 4 .. buffer'First + 7));
        header.Token_Event := U32_Be (buffer (buffer'First + 8 .. buffer'First + 11));
        return header;
    end Ril_Be;

    -----------
    -- Valid --
    -----------

    function Valid
      (header : Fw_Types.Eth;
       payload : Fw_Types.Buffer)
       return Boolean
    is
        v : Boolean := payload'Length <= 1500;
    begin
        v := v and payload'Length >= 46;
        v := v and header.Source.NIC_2 /= 0;
        return v;
    end Valid;

    -----------
    -- Valid --
    -----------

    function Valid
      (header : Fw_Types.Sl3p;
       payload : Fw_Types.Buffer;
       sequence : Fw_Types.U64)
       return Boolean
    is
        v : Boolean := header.Sequence_number > 0;
    begin
        v := v and (header.Sequence_number > sequence);
        v := v and header.Length <= 1488;
        if header.Length <= 34 then
            v := v and payload'Length = 34;
        else
            v := v and (payload'Length = header.Length);
        end if;
        return v;
    end Valid;

    -----------
    -- Valid --
    -----------

    function Valid
      (header : Fw_Types.RIL;
       payload : Fw_Types.Buffer)
       return Boolean
    is
        v : constant Boolean := header.Length = payload'Length;
    begin
        return v;
    end Valid;

end Dissector;
