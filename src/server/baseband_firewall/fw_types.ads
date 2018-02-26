
package Fw_Types
is

    type U04 is mod 16;
    for U04'Size use 4;

    type U08 is mod 256;
    for U08'Size use 8;

    type U16 is mod 2**16;
    for U16'Size use 16;

    type U32 is mod 2**32;
    for U32'Size use 32;

    type U64 is mod 2**64;
    for U64'Size use 64;

    subtype H08 is String (1 .. 2);
    subtype H16 is String (1 .. 4);
    subtype H32 is String (1 .. 8);

    function Exp
        (Base     : U32;
         Exponent : U32) return U64
    with
        Pre  => Exponent <= U32 (Natural'Last),
        Post => (Exp'Result = U64 (Base ** Natural (Exponent)));

    type Buffer is array (U32 range <>) of U08;

    type Mac is
        record
            OUI_0 : U08;
            OUI_1 : U08;
            OUI_2 : U08;
            NIC_0 : U08;
            NIC_1 : U08;
            NIC_2 : U08;
        end record with
      Size => 48;

    for Mac use
        record
            OUI_0 at 0 range 0 .. 7;
            OUI_1 at 1 range 0 .. 7;
            OUI_2 at 2 range 0 .. 7;
            NIC_0 at 3 range 0 .. 7;
            NIC_1 at 4 range 0 .. 7;
            NIC_2 at 5 range 0 .. 7;
        end record;

    type Eth is
        record
            Destination : Mac;
            Source      : Mac;
            Ethtype     : U16;
        end record with
      Size => 112;

    for Eth use
        record
            Destination at  0 range 0 .. 47;
            Source      at  6 range 0 .. 47;
            Ethtype     at 12 range 0 .. 15;
        end record;

    Eth_Offset : constant U32 := 14;

    type Sl3p is
        record
            Sequence_number : U64;
            Length : U32;
        end record with
      Size => 96;

    for Sl3p use
        record
            Sequence_Number at 0 range 0 .. 63;
            Length          at 8 range 0 .. 31;
        end record;

    Sl3p_Offset : constant U32 := 12;

    type RIL is record
        Length      : U32;
        ID          : U32;
        Token_Event : U32;
    end record with
      Size => 96;

    for RIL use
        record
            Length      at 0 range 0 .. 31;
            ID          at 4 range 0 .. 31;
            Token_Event at 8 range 0 .. 31;
        end record;

    RIL_Offset : constant U32 := 12;

    type Packet is record
        Eth_Header : Eth;
        Sl3p_Header : Sl3p;
        RIL_Header : RIL;
    end record with
      Size => 304;

    for Packet use
        record
            Eth_Header  at  0 range 0 .. 111;
            Sl3p_header at 14 range 0 ..  95;
            RIL_Header  at 26 range 0 ..  95;
        end record;

    type Direction is (Unknown, BP, AP);
    for Direction use (Unknown => 0, BP => 1, AP => 2);

    type Status is (Accepted, Rejected);

    function Image (Val : U08) return H08
      with
        Depends => (Image'Result => Val);

    function Image (Val : U16) return H16
      with
        Depends => (Image'Result => Val);

    function Image (Val : U32) return H32
      with
        Depends => (Image'Result => Val);

private

    function Hex (Value : U08) return Character
    is
        (
            if Value < 10 then
                Character'Val (Integer (Value) + 48)
            else
                Character'Val (Integer (Value) + 87)
        )
    with
        Pre     => Value <= 16#f#,
        Depends => (Hex'Result => Value),
        Post    => ((Hex'Result in '0' .. '9') or (Hex'Result in 'a' .. 'f'));

end Fw_Types;
