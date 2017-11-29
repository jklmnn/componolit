with fw_log;
with fw_types;
use all type fw_types.Nibble;
use all type fw_types.Byte;
use all type fw_types.Buffer;

package body baseband_fw is

    procedure filter(
        dest: System.Address;
        src: System.Address;
        dest_size: Integer;
        src_size: Integer;
        dir: Integer) 
    is
        dest_buf: fw_types.Buffer (0 .. dest_size);
        src_buf: fw_types.Buffer (0 .. src_size);
        src_packet: fw_types.packet;
        for dest_buf'Address use dest;
        for src_buf'Address use src;
        for src_packet'Address use src;
        packet_status: fw_types.Status := analyze(src_packet, fw_types.Direction'Val(dir));
    begin
        copy(dest_buf, src_buf);
    end;

    procedure copy (
        dest: out fw_types.Buffer;
        src: in fw_types.Buffer) with
        SPARK_Mode is
    begin
        dest := src;
    end;

    function analyze (
        source: in fw_types.Packet;
        dir: in fw_types.Direction) return fw_types.Status with
        SPARK_Mode
    is
        s_ip: String(1..8);
        d_ip: String(1..8);

        udp_s_port: String(1..4);
        udp_d_port: String(1..4);
        udp_length: String(1..4);
        udp_checksum: String(1..4);
        
        ril_id: String(1..8);
        ril_length: String(1..8);
        ril_token: String(1..8);
      
        proto: constant fw_types.Byte := (1,1);
        port: constant fw_types.Port := ((4,9), (14,0));
        c_ril_l: constant fw_types.Buffer := ((0,0), (0,0), (0,0), (0,4));
        c_ril_setup: constant fw_types.Buffer := ((1, 5), (12, 7), (0,0), (0,0));
        c_ril_teardown: constant fw_types.Buffer := ((1, 7), (12, 7), (0,0), (0,0));
        test1: constant fw_types.Byte := (0, 4);
        test2: constant fw_types.Byte := (4, 0);
        test3: constant fw_types.Byte := (10, 10);
        test4: constant fw_types.Byte := (15, 15);

    begin
        if source.ip_header.Protocol = proto and then
          (source.udp_header.source = port and source.udp_header.destination = port) and then
          (source.ril_packet.Length = c_ril_l and 
          (source.ril_packet.ID = c_ril_setup or source.ril_packet.ID = c_ril_teardown)) then

            fw_log.hex_dump(source.ip_header.source, s_ip);
            fw_log.hex_dump(source.ip_header.destination, d_ip);

            fw_log.hex_dump(source.udp_header.source, udp_s_port);
            fw_log.hex_dump(source.udp_header.destination, udp_d_port);
            fw_log.hex_dump(source.udp_header.length, udp_length);
            fw_log.hex_dump(source.udp_header.checksum, udp_checksum);

            fw_log.hex_dump(source.ril_packet.id, ril_id);
            fw_log.hex_dump(source.ril_packet.length, ril_length);
            fw_log.hex_dump(source.ril_packet.Token_event, ril_token);

            fw_log.log_int(fw_types.int_value(source.ril_packet.Length));
            fw_log.log_int(fw_types.int_value(source.ril_packet.ID));
            fw_log.log(fw_log.directed_arrow(dir) & " " &
                ril_length & " " & ril_id & " " & ril_token);
        end if;
        return fw_types.ACCEPTED;
    end;

end baseband_fw;
