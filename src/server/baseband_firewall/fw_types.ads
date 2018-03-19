with System;

package Fw_Types
is

    type Byte is mod 256
      with Size => 16;

    type Word is mod 2 ** 16
      with Size => 16;

    type Double_Word is mod 2 ** 32
      with Size => 32;

    type Quad_Word is mod 2 ** 64
      with Size => 64;

    type U08 is new Integer range 0 .. 2 ** 8 - 1
      with Size => 8;

    type U16 is new Integer range 0 .. 2 ** 16 - 1
      with Size => 16;

    type U32 is new Long_Integer range 0 .. 2 ** 32 - 1
      with Size => 32;
    subtype U32_Index is U32 range U32'First .. U32'Last - 1;

    type U64 is mod 2**64;
    for U64'Size use 64;

    type Buffer is array (U32_Index range <>) of Byte;

    subtype H08 is String (1 .. 2);
    subtype H16 is String (1 .. 4);
    subtype H32 is String (1 .. 8);

    function Exp
        (Base     : U32;
         Exponent : U32) return U64
    with
        Pre  => Exponent <= U32 (Natural'Last),
        Post => (Exp'Result = U64 (Base ** Natural (Exponent)));

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

    function Image (Val : Byte) return H08
      with
        Depends => (Image'Result => Val);

    function Image (Val : Word) return H16
      with
        Depends => (Image'Result => Val);

    function Image (Val : Double_Word) return H32
      with
        Depends => (Image'Result => Val);

    type Process is
        record
            Instance : System.Address;
            NIC      : Integer;
        end record;

private

    function Hex (Value : Byte) return Character
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
