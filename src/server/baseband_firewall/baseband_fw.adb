with fw_log;

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
--        ril_length: String(1..4);
--        ril_id: String(1..4);
--        udp_port: String(1..2);
--        udp_length: String(1..2);
        d_ip: String(1..4);
        d_ip_length: String(1..2);
    begin
--        fw_log.hex_dump(source.ril_packet.Length, ril_length);
--        fw_log.hex_dump(source.ril_packet.id, ril_id);
--        fw_log.log(fw_log.directed_arrow(dir) & " " & ril_length & ":" & ril_id, fw_log.debug);
--        fw_log.hex_dump(source.udp_header.destination, udp_port);
--        fw_log.hex_dump(source.udp_header.Length, udp_length);
--        fw_log.log(fw_log.directed_arrow(dir) & " " & udp_port & " (" & udp_length & ") ", fw_log.debug);
        fw_log.hex_dump(source.ip_header.destination, d_ip);
        fw_log.hex_dump(source.ip_header.total_length, d_ip_length);
        fw_log.log(fw_log.directed_arrow(dir) & " " & d_ip & ":" & d_ip_length, fw_log.debug);
        return fw_types.ACCEPTED;
    end;

end baseband_fw;
