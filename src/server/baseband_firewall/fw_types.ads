
package fw_types with SPARK_Mode
is
    
    type U32 is mod 4294967296;
    
    function exp(base: U32; exp: U32) return U32;
    
    type Nibble is mod 16;
    for Nibble'Size use 4;
    
    type Byte is record
        lower: Nibble;
        upper: Nibble;
    end record;
    
    for Byte use 
        record
            upper at 0 range 0 .. 3;
            lower at 0 range 4 .. 7;
        end record;
    for Byte'Size use 8;
    
    function int_value(b: Byte) return U32 is
        (U32(b.lower) * 16 + U32(b.upper)) with SPARK_Mode;
    
    type Buffer is array (integer range <>) of Byte;
    
    function int_value(b: Buffer) return U32 with
      SPARK_Mode,
        Pre => (b'Length < 5) and (int_value(b(b'First)) < 128);
    
    subtype Mac is Buffer(0 .. 5);
    subtype IP_address is Buffer(0 .. 3);
    subtype Port is Buffer(0 .. 1);

    type Eth is record
        source : Mac;
        destination : Mac;
        size : Buffer(0 .. 1);
    end record;

    for Eth use
        record
            source at 0 range 0 .. 47;
            destination at 6 range 0 .. 47;
            size at 12 range 0 .. 15;
        end record;
    for Eth'Size use 112;

    type IP is record
        version: Nibble;
        header_length: Nibble;
        total_length: Buffer (0 .. 1);
        identification: Buffer (0 .. 1);
        ttl: Byte;
        Protocol: Byte;
        checksum: Buffer (0 .. 1);
        source: IP_address;
        destination: IP_address;
    end record;

    for IP use
        record
            version at 0 range 0 .. 3;
            header_length at 0 range 4 .. 7;
            total_length at 2 range 0 .. 15;
            identification at 4 range 0 .. 15;
            ttl at 8 range 0 .. 7;
            Protocol at 9 range 0 .. 7;
            checksum at 10 range 0 .. 15;
            source at 12 range 0 .. 31;
            destination at 16 range 0 .. 31;
        end record;
    for IP'Size use 160;

    type UDP is record
        source: Port;
        destination: Port;
        Length: Buffer(0 .. 1);
        Checksum: Buffer(0 .. 1);
    end record;

    for UDP use
        record
            source at 0 range 0 .. 15;
            destination at 2 range 0 .. 15;
            Length at 4 range 0 .. 15;
            Checksum at 6 range 0 .. 15;
        end record;
    for UDP'Size use 64;

    type RIL is record
        Length: Buffer (0 .. 3);
        ID: Buffer (0 .. 3);
        Token_event: Buffer (0 .. 3);
    end record;

    for RIL use
        record
            Length at 0 range 0 .. 31;
            ID at 4 range 0 .. 31;
            Token_event at 8 range 0 .. 31;
        end record;
    for RIL'Size use 96;

    type packet is record
        eth_header: Eth;
        ip_header: IP;
        udp_header: UDP;
        ril_packet: RIL;
    end record;

    for packet use
        record
            eth_header at 0 range 0 .. 111;
            ip_header at 14 range 0 .. 159;
            udp_header at 34 range 0 .. 63;
            ril_packet at 42 range 0 .. 95;
        end record;
    for packet'Size use 432;
    
    type Direction is (UNKNOWN, AP, BP);
    for Direction use (UNKNOWN => 0, AP => 1, BP => 2);

    type Status is (ACCEPTED, REJECTED);

end fw_types;
