with fw_log;
with fw_types;
use all type fw_types.Nibble;

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
        
        ril_id: String(1..8);
        ril_length: String(1..8);
      
    begin
        if source.ip_header.Protocol.lower = 1 and source.ip_header.Protocol.upper = 1 then
            fw_log.hex_dump(source.ip_header.source, s_ip);
            fw_log.hex_dump(source.ip_header.destination, d_ip);

            fw_log.hex_dump(source.udp_header.source, udp_s_port);
            fw_log.hex_dump(source.udp_header.destination, udp_d_port);

            fw_log.hex_dump(source.ril_packet.id, ril_id);
            fw_log.hex_dump(source.ril_packet.length, ril_length);

            fw_log.log(fw_log.directed_arrow(dir) & " " &
                s_ip(1..2) & "." & s_ip(3..4) & "." & s_ip(5..6) & "." & s_ip(7..8) & ":" & udp_s_port &
                " -> " &
                d_ip(1..2) & "." & d_ip(3..4) & "." & d_ip(5..6) & "." & d_ip(7..8) & ":" & udp_d_port &
                " " & ril_id & " " & ril_length, fw_log.debug);
        end if;
        return fw_types.ACCEPTED;
    end;

end baseband_fw;
