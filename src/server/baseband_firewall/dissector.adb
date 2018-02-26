pragma Ada_2012;

package body Dissector
with
SPARK_Mode
is

    pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");

    function UXX_Be (
                     Buffer : Fw_Types.Buffer
                    ) return UXX
    is
        value : UXX := 0;
    begin
        for i in Fw_Types.U32 range 0 .. (UXX'Size / 8) - 1 loop
            pragma Loop_Invariant (Buffer'Length > (UXX'Size / 8) - 1);
            value := value + UXX (Buffer (Buffer'Last - Fw_Types.U32 (i))) * UXX (Fw_Types.Exp (256, i));
        end loop;
        return value;
    end UXX_Be;

    function U16_Be is new UXX_Be (Fw_Types.U16);
    function U32_Be is new UXX_Be (Fw_Types.U32);
    function U64_Be is new UXX_Be (Fw_Types.U64);

    ------------
    -- Eth_Be --
    ------------

    function Eth_Be (
                     Buffer : Fw_Types.Buffer
                    ) return Fw_Types.Eth
    is
        Header : Fw_Types.Eth;
        Ethtype : Fw_Types.Buffer (0 .. 1) := (0, 0);
    begin
        Ethtype (0) := Buffer (Buffer'First + 12);
        Ethtype (1) := Buffer (Buffer'First + 13);

        pragma Assert (Buffer'First + 13 <= Buffer'Last);
        Header.Destination.OUI_0 := Buffer (Buffer'First + 0);
        Header.Destination.OUI_1 := Buffer (Buffer'First + 1);
        Header.Destination.OUI_2 := Buffer (Buffer'First + 2);
        Header.Destination.NIC_0 := Buffer (Buffer'First + 3);
        Header.Destination.NIC_1 := Buffer (Buffer'First + 4);
        Header.Destination.NIC_2 := Buffer (Buffer'First + 5);

        Header.Source.OUI_0 := Buffer (Buffer'First + 6);
        Header.Source.OUI_1 := Buffer (Buffer'First + 7);
        Header.Source.OUI_2 := Buffer (Buffer'First + 8);
        Header.Source.NIC_0 := Buffer (Buffer'First + 9);
        Header.Source.NIC_1 := Buffer (Buffer'First + 10);
        Header.Source.NIC_2 := Buffer (Buffer'First + 11);

        pragma Assert (Fw_Types.U16'Size / 8 = 2);
        pragma Assert (Ethtype'Length = 2);
        Header.Ethtype := U16_Be (Ethtype);

        return Header;
    end Eth_Be;

    -------------
    -- Sl3p_Be --
    -------------

    function Sl3p_Be
      (
       Buffer : Fw_Types.Buffer
      ) return Fw_Types.Sl3p
    is
        Header : Fw_Types.Sl3p;
    begin
        Header.Sequence_number := U64_Be (Buffer (Buffer'First .. Buffer'First + 7));
        Header.Length := U32_Be (Buffer (Buffer'First + 8 .. Buffer'First + 11));
        return Header;
    end Sl3p_Be;

    ------------
    -- Ril_Be --
    ------------

    function Ril_Be
      (
       Buffer : Fw_Types.Buffer
      ) return Fw_Types.RIL
    is
        Header : Fw_Types.RIL;
    begin
        Header.Length := U32_Be (Buffer (Buffer'First .. Buffer'First + 3));
        Header.ID := U32_Be (Buffer (Buffer'First + 4 .. Buffer'First + 7));
        Header.Token_Event := U32_Be (Buffer (Buffer'First + 8 .. Buffer'First + 11));
        return Header;
    end Ril_Be;

    -----------
    -- Valid --
    -----------

    function Valid (
                    Header : Fw_Types.Eth;
                    Payload : Fw_Types.Buffer;
                    Dir     : Fw_Types.Direction
                   ) return Boolean
    is
        v : Boolean := Payload'Length <= 1500;
    begin
        v := v and Payload'Length >= 46;
        --  Mac address : 2a:43:4d:50:2a:0(a|b)
        v := v and Header.Source.OUI_0 = 16#2a#;
        v := v and Header.Source.OUI_1 = 16#43#;
        v := v and Header.Source.OUI_2 = 16#4d#;
        v := v and Header.Source.NIC_0 = 16#50#;
        v := v and Header.Source.NIC_1 = 16#2a#;
        case Dir is
            when Fw_Types.BP =>
                v := v and Header.Source.NIC_2 = 16#0b#;
            when Fw_Types.AP =>
                v := v and Header.Source.NIC_2 = 16#0a#;
            when others =>
                v := False;
        end case;
        return v;
    end Valid;

    -----------
    -- Valid --
    -----------

    function Valid (
                    Header   : Fw_Types.Sl3p;
                    Payload  : Fw_Types.Buffer;
                    Sequence : Fw_Types.U64
                   ) return Boolean
    is
        v : Boolean := Header.Sequence_number > 0;
    begin
        v := v and (Header.Sequence_number > Sequence);
        v := v and Header.Length <= 1488;
        if Header.Length <= 34 then
            v := v and Payload'Length = 34;
        else
            v := v and (Payload'Length = Header.Length);
        end if;
        return v;
    end Valid;

    -----------
    -- Valid --
    -----------

    function Valid (
                    Header : Fw_Types.RIL;
                    Payload : Fw_Types.Buffer
                   ) return Boolean
    is
        v : constant Boolean := Header.Length = Payload'Length;
    begin
        return v;
    end Valid;

end Dissector;
