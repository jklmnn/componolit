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
        Value : UXX := 0;
    begin
        for I in Fw_Types.U32_Index range 0 .. (UXX'Size / 8) - 1 loop
            pragma Loop_Invariant (Buffer'Length > (UXX'Size / 8) - 1);
            Value := Value + UXX (Buffer (Buffer'Last -  I)) * UXX (Fw_Types.Exp (256, Fw_Types.U32 (I)));
        end loop;
        return Value;
    end UXX_Be;

    function U16_Be is new UXX_Be (Fw_Types.Word);
    function U32_Be is new UXX_Be (Fw_Types.Double_Word);
    function U64_Be is new UXX_Be (Fw_Types.Quad_Word);

    procedure Be_UXX (
                      Value  : UXX;
                      Buffer : out Fw_Types.Buffer
                     )
    is
        V : UXX := Value;
    begin
        Buffer := (others => 0);
        for I in reverse Buffer'Range loop
            Buffer (I) := Fw_Types.Byte (V and 16#ff#);
            V := V / 256;
        end loop;
    end Be_UXX;

    procedure Be_U16 is new Be_UXX (Fw_Types.Word);
    procedure Be_U32 is new Be_UXX (Fw_Types.Double_Word);
    procedure Be_U64 is new Be_UXX (Fw_Types.Quad_Word);

    ------------
    -- Eth_Be --
    ------------

    function Eth_Be (
                     Buffer : Fw_Types.Buffer
                    ) return Eth
    is
        Header : Eth;
        Ethtype : Fw_Types.Buffer (0 .. 1) := (0, 0);
    begin
        Ethtype (0) := Buffer (Buffer'First + 12);
        Ethtype (1) := Buffer (Buffer'First + 13);

        pragma Assert (Buffer'First + 13 <= Buffer'Last);
        Header.Destination.OUI_0 := Fw_Types.U08 (Buffer (Buffer'First + 0));
        Header.Destination.OUI_1 := Fw_Types.U08 (Buffer (Buffer'First + 1));
        Header.Destination.OUI_2 := Fw_Types.U08 (Buffer (Buffer'First + 2));
        Header.Destination.NIC_0 := Fw_Types.U08 (Buffer (Buffer'First + 3));
        Header.Destination.NIC_1 := Fw_Types.U08 (Buffer (Buffer'First + 4));
        Header.Destination.NIC_2 := Fw_Types.U08 (Buffer (Buffer'First + 5));

        Header.Source.OUI_0 := Fw_Types.U08 (Buffer (Buffer'First + 6));
        Header.Source.OUI_1 := Fw_Types.U08 (Buffer (Buffer'First + 7));
        Header.Source.OUI_2 := Fw_Types.U08 (Buffer (Buffer'First + 8));
        Header.Source.NIC_0 := Fw_Types.U08 (Buffer (Buffer'First + 9));
        Header.Source.NIC_1 := Fw_Types.U08 (Buffer (Buffer'First + 10));
        Header.Source.NIC_2 := Fw_Types.U08 (Buffer (Buffer'First + 11));

        pragma Assert (Fw_Types.U16'Size / 8 = 2);
        pragma Assert (Ethtype'Length = 2);
        Header.Ethtype := Fw_Types.U16 (U16_Be (Ethtype));

        return Header;
    end Eth_Be;

    procedure Eth_Be (
                      Header : Eth;
                      Buffer : out Fw_Types.Buffer
                    )
    is
    begin
        Buffer := (others => 0);
        Buffer (Buffer'First + 0) := Fw_Types.Byte (Header.Destination.OUI_0);
        Buffer (Buffer'First + 1) := Fw_Types.Byte (Header.Destination.OUI_1);
        Buffer (Buffer'First + 2) := Fw_Types.Byte (Header.Destination.OUI_2);
        Buffer (Buffer'First + 3) := Fw_Types.Byte (Header.Destination.NIC_0);
        Buffer (Buffer'First + 4) := Fw_Types.Byte (Header.Destination.NIC_1);
        Buffer (Buffer'First + 5) := Fw_Types.Byte (Header.Destination.NIC_2);

        Buffer (Buffer'First +  6) := Fw_Types.Byte (Header.Source.OUI_0);
        Buffer (Buffer'First +  7) := Fw_Types.Byte (Header.Source.OUI_1);
        Buffer (Buffer'First +  8) := Fw_Types.Byte (Header.Source.OUI_2);
        Buffer (Buffer'First +  9) := Fw_Types.Byte (Header.Source.NIC_0);
        Buffer (Buffer'First + 10) := Fw_Types.Byte (Header.Source.NIC_1);
        Buffer (Buffer'First + 11) := Fw_Types.Byte (Header.Source.NIC_2);

        pragma Assert (Buffer (Buffer'First + 12 .. Buffer'First + 13)'Length = Fw_Types.U16'Size / 8);
        Be_U16 (Fw_Types.Word (Header.Ethtype), Buffer (Buffer'First + 12 .. Buffer'First + 13));
    end Eth_Be;

    -------------
    -- Sl3p_Be --
    -------------

    function Sl3p_Be (
                      Buffer : Fw_Types.Buffer
                     ) return Sl3p
    is
        Header : Sl3p;
    begin
        Header.Sequence_Number := Fw_Types.U64 (U64_Be (Buffer (Buffer'First .. Buffer'First + 7)));
        Header.Length := Fw_Types.U32 (U32_Be (Buffer (Buffer'First + 8 .. Buffer'First + 11)));
        return Header;
    end Sl3p_Be;

    procedure Sl3p_Be (
                       Header : Sl3p;
                       Buffer : out Fw_Types.Buffer
                      )
    is
    begin
        Buffer := (others => 0);
        pragma Assert (Buffer (Buffer'First .. Buffer'First + 7)'Length = Fw_Types.U64'Size / 8);
        Be_U64 (Fw_Types.Quad_Word (Header.Sequence_Number), Buffer (Buffer'First .. Buffer'First + 7));
        Be_U32 (Fw_Types.Double_Word (Header.Length), Buffer (Buffer'First + 8 .. Buffer'First + 11));
    end Sl3p_Be;

    ------------
    -- Ril_Be --
    ------------

    function Ril_Be (
                     Buffer : Fw_Types.Buffer
                    ) return RIL
    is
        Header : RIL;
    begin
        Header.Length := Fw_Types.U32 (U32_Be (Buffer (Buffer'First .. Buffer'First + 3)));
        pragma Assert (Buffer (Buffer'First + 4 .. Buffer'First + 7)'Length = Fw_Types.U32'Size / 8);
        Header.ID := Fw_Types.U32 (U32_Be (Buffer (Buffer'First + 4 .. Buffer'First + 7)));
        pragma Assert (Buffer (Buffer'First + 8 .. Buffer'First + 11)'Length = Fw_Types.U32'Size / 8);
        Header.Token_Event := Fw_Types.U32 (U32_Be (Buffer (Buffer'First + 8 .. Buffer'First + 11)));
        return Header;
    end Ril_Be;

    -----------
    -- Valid --
    -----------

    function Valid (
                    Header : Eth;
                    Payload : Fw_Types.Buffer;
                    Dir     : Fw_Types.Direction
                   ) return Result
    is
        v : Result := Unchecked;
    begin
        Check_Condition (v, Payload'Length <= 1500, Payload_To_Long);
        Check_Condition (v, Payload'Length >= 46, Payload_To_Short);
        --  Mac address : 2a:43:4d:50:2a:0(a|b)
        Check_Condition (v, Header.Source.OUI_0 = 16#2a#, Forbidden_Address);
        Check_Condition (v, Header.Source.OUI_1 = 16#43#, Forbidden_Address);
        Check_Condition (v, Header.Source.OUI_2 = 16#4d#, Forbidden_Address);
        Check_Condition (v, Header.Source.NIC_0 = 16#50#, Forbidden_Address);
        Check_Condition (v, Header.Source.NIC_1 = 16#2a#, Forbidden_Address);
        case Dir is
            when Fw_Types.BP =>
                Check_Condition (v, Header.Source.NIC_2 = 16#0b#, Invalid_Direction);
            when Fw_Types.AP =>
                Check_Condition (v, Header.Source.NIC_2 = 16#0a#, Invalid_Direction);
            when others =>
                Check_Condition (v, False, Invalid_Direction);
        end case;
        return (if v = Unchecked then Checked else v);
    end Valid;

    -----------
    -- Valid --
    -----------

    function Valid (
                    Header   : Sl3p;
                    Payload  : Fw_Types.Buffer;
                    Sequence : Fw_Types.U64
                   ) return Result
    is
        v : Result := Unchecked;
    begin
        Check_Condition (v, Header.Sequence_Number > 0, Invalid_Sequence_Number);
        Check_Condition (v, Header.Sequence_Number > Sequence, Invalid_Sequence_Number);
        Check_Condition (v, Header.Length <= 1488, Invalid_Size);
        if Header.Length <= 34 then
            Check_Condition (v, Payload'Length = 34, Invalid_Size);
        else
            Check_Condition (v, Payload'Length = Header.Length, Invalid_Size);
        end if;
        return (if v = Unchecked then Checked else v);
    end Valid;

    -----------
    -- Valid --
    -----------

    function Valid (
                    Header  : RIL;
                    Payload : Fw_Types.Buffer
                   ) return Result
    is
        v : Result := Unchecked;
    begin
        Check_Condition (v, Header.Length <= Payload'Length, Invalid_Size);
        Check_Condition (v, Header.Length > 0, Invalid_Size);
        return (if v = Unchecked then Checked else v);
    end Valid;

    procedure Check_Condition (
                               Status : in out Result;
                               Condition : Boolean;
                               Result_On_False : Result
                              )
    is
    begin
        if Status = Unchecked then
            Status := (if Condition then Status else Result_On_False);
        end if;
    end Check_Condition;

    function Image (
                    R : Result
                   ) return Result_String
    is
        RS : Result_String;
    begin
        case R is
            when Checked =>
                RS := "Checked";
            when Unchecked =>
                RS := "Uncheck";
            when Payload_To_Short =>
                RS := "Pl_Shrt";
            when Payload_To_Long =>
                RS := "Pl_Long";
            when Invalid_Sequence_Number =>
                RS := "Inv_Seq";
            when Invalid_Size =>
                RS := "Inv_Siz";
            when Invalid_Direction =>
                RS := "Inv_Dir";
            when Forbidden_Address =>
                RS := "Fb_Addr";
        end case;
        return RS;
    end Image;

end Dissector;
