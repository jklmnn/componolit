
package fw_types is


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

    type Buffer is array (integer range <>) of Byte;
    subtype Mac is Buffer(0 .. 5);

    type Eth is record
        source : Mac;
        destination : Mac;
        size : Buffer(0 .. 1);
    end record;

    type packet is record
        eth_header: Eth;
   --     ip_header: IP;
   --     udp_header: UDP;
   --     ril_packet: RIL;
    end record;
    
end fw_types;
