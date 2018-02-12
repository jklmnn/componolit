with System;

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
         Exponent : U32) return U32
    with
        Pre  => Exponent <= U32 (Natural'Last),
        Post => (Exp'Result = Base ** Natural (Exponent));

    type Buffer is array (Integer range <>) of U08;

    type Mac is
        record
            OUI_0 : U08;
            OUI_1 : U08;
            OUI_2 : U08;
            NIC_0 : U08;
            NIC_1 : U08;
            NIC_2 : U08;
        end record;

    for Mac use
        record
            OUI_0 at 0 range 0 .. 7;
            OUI_1 at 1 range 0 .. 7;
            OUI_2 at 2 range 0 .. 7;
            NIC_0 at 3 range 0 .. 7;
            NIC_1 at 4 range 0 .. 7;
            NIC_2 at 5 range 0 .. 7;
        end record;
    for Mac'Size use 48;
    for Mac'Bit_Order use System.High_Order_First;
    for Mac'Scalar_Storage_Order use System.High_Order_First;

    type Eth is
    record
        Source      : Mac;
        Destination : Mac;
        Ethtype     : U16;
    end record;

    for Eth use
        record
            Source      at  0 range 0 .. 47;
            Destination at  6 range 0 .. 47;
            Ethtype     at 12 range 0 .. 15;
        end record;
    for Eth'Size use 112;
    for Eth'Bit_Order use System.High_Order_First;
    for Eth'Scalar_Storage_Order use System.High_Order_First;

    type Sl3p is
        record
            Sequence_number : U64;
            Length : U32;
        end record;

    for Sl3p use
      record
            Sequence_Number at 0 range 0 .. 63;
            Length          at 8 range 0 .. 31;
      end record;
    for Sl3p'Size use 96;
    for Sl3p'Bit_Order use System.High_Order_First;
    for Sl3p'Scalar_Storage_Order use System.High_Order_First;

    type RIL is record
        Length      : U32;
        ID          : U32;
        Token_Event : U32;
    end record;

    for RIL use
        record
            Length      at 0 range 0 .. 31;
            ID          at 4 range 0 .. 31;
            Token_Event at 8 range 0 .. 31;
        end record;
    for RIL'Size use 96;
    for RIL'Bit_Order use System.High_Order_First;
    for RIL'Scalar_Storage_Order use System.High_Order_First;

    type Packet is record
        Eth_Header : Eth;
        Sl3p_Header : Sl3p;
        RIL_Header : RIL;
    end record;

    for Packet use
        record
            Eth_Header  at  0 range 0 .. 111;
            Sl3p_header at 14 range 0 ..  95;
            RIL_Header  at 26 range 0 ..  95;
        end record;
    for Packet'Size use 304;

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
