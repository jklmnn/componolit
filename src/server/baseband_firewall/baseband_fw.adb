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
        direction: in fw_types.Direction) return fw_types.Status with
        SPARK_Mode
    is
        src_mac: String(1 .. 12);
        dst_mac: String(1 .. 12);
    begin
        fw_log.hex_dump(source.eth_header.source, src_mac);
        fw_log.hex_dump(source.eth_header.destination, dst_mac);
        fw_log.log(src_mac & " " & fw_log.directed_arrow(direction) & " " & dst_mac, fw_log.debug);
        return fw_types.ACCEPTED;
    end;

end baseband_fw;
