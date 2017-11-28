with fw_log;

package body baseband_fw is

    procedure filter(
        dest: System.Address;
        src: System.Address;
        dest_size: Integer;
        src_size: Integer) 
    is
        dest_buf: fw_types.Buffer (0 .. dest_size);
        src_buf: fw_types.Buffer (0 .. src_size);
        p: fw_types.packet;
        for dest_buf'Address use dest;
        for src_buf'Address use src;
        for p'Address use src;
        src_mac: String(1 .. 12);
        dst_mac: String(1 .. 12);
    begin
        fw_log.hex_dump(p.eth_header.source, src_mac);
        fw_log.hex_dump(p.eth_header.destination, dst_mac);
        fw_log.log(src_mac & " -> " & dst_mac, fw_log.debug);
        filter_spark(dest_buf, src_buf);
    end;



    procedure filter_spark (
        dest: out fw_types.Buffer;
        src: in fw_types.Buffer) with
        SPARK_Mode is
    begin
        dest := src;
    end;

end baseband_fw;
