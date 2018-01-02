package Fw_Types
is

    type U32 is mod 2**32;

    function Exp
        (Base     : U32;
         Exponent : U32) return U32
    with
        Pre  => Exponent <= U32 (Natural'Last),
        Post => (Exp'Result = Base ** Natural (Exponent));

    type Nibble is mod 16;
    for Nibble'Size use 4;

    type Byte is mod 256;
    for Byte'Size use 8;

    type Buffer is array (Integer range <>) of Byte;

    subtype Buffer_2 is Buffer (0 .. 1);
    subtype Buffer_4 is Buffer (0 .. 3);
    subtype Buffer_6 is Buffer (0 .. 5);

    function Get_U32_BE (Buf : Buffer_4) return U32 is
        (U32 (Buf (0)) + 256 * U32 (Buf (1)) + 65536 * U32 (Buf (2)) + 16777216 * U32 (Buf (3)));

    pragma Assert (Get_U32_BE (Buffer_4'(1, 0, 0, 0)) = 1);

    subtype Mac is Buffer_6;
    type IP_address is new Buffer_4;
    subtype Port is Buffer_2;

    type Eth is
    record
        Source      : Mac;
        Destination : Mac;
        Size        : Buffer (0 .. 1);
    end record;

    for Eth use
        record
            Source      at  0 range 0 .. 47;
            Destination at  6 range 0 .. 47;
            Size        at 12 range 0 .. 15;
        end record;
    for Eth'Size use 112;

    type IP is record
        Version        : Nibble;
        Header_Length  : Nibble;
        Total_Length   : Buffer (0 .. 1);
        Identification : Buffer (0 .. 1);
        TTL            : Byte;
        Protocol       : Byte;
        Checksum       : Buffer (0 .. 1);
        Source         : IP_address;
        Destination    : IP_address;
    end record;

    for IP use
        record
            Version        at  0 range 0 ..  3;
            Header_Length  at  0 range 4 ..  7;
            Total_Length   at  2 range 0 .. 15;
            Identification at  4 range 0 .. 15;
            TTL            at  8 range 0 ..  7;
            Protocol       at  9 range 0 ..  7;
            Checksum       at 10 range 0 .. 15;
            Source         at 12 range 0 .. 31;
            Destination    at 16 range 0 .. 31;
        end record;
    for IP'Size use 160;

    type UDP is record
        Source      : Port;
        Destination : Port;
        Length      : Buffer (0 .. 1);
        Checksum    : Buffer (0 .. 1);
    end record;

    for UDP use
        record
            Source      at 0 range 0 .. 15;
            Destination at 2 range 0 .. 15;
            Length      at 4 range 0 .. 15;
            Checksum    at 6 range 0 .. 15;
        end record;
    for UDP'Size use 64;

    type RIL is record
        Length      : Buffer (0 .. 3);
        ID          : Buffer (0 .. 3);
        Token_Event : Buffer (0 .. 3);
    end record;

    for RIL use
        record
            Length      at 0 range 0 .. 31;
            ID          at 4 range 0 .. 31;
            Token_Event at 8 range 0 .. 31;
        end record;
    for RIL'Size use 96;

    type Packet is record
        Eth_Header : Eth;
        IP_Header  : IP;
        UDP_Header : UDP;
        RIL_Packet : RIL;
    end record;

    for Packet use
        record
            Eth_Header at  0 range 0 .. 111;
            IP_Header  at 14 range 0 .. 159;
            UDP_Header at 34 range 0 ..  63;
            RIL_Packet at 42 range 0 ..  95;
        end record;
    for Packet'Size use 432;

    type Direction is (Unknown, BP, AP);
    for Direction use (Unknown => 0, BP => 1, AP => 2);

    type Status is (Accepted, Rejected);

end Fw_Types;
