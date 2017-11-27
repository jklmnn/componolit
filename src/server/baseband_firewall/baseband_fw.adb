
package body baseband_fw is

    procedure filter(
        dest: System.Address;
        src: System.Address;
        dest_size: Integer;
        src_size: Integer) 
    is
        dest_buf: Buffer (0 .. dest_size);
        src_buf: Buffer (0 .. src_size);
        p: packet;
        for dest_buf'Address use dest;
        for src_buf'Address use src;
        for p'Address use src;
        src_mac: String(1 .. 12) := (others => '_');
        dst_mac: String(1 .. 12) := (others => '_');
    begin
        hex_dump(p.eth_header.source, src_mac);
        hex_dump(p.eth_header.destination, dst_mac);
        log(src_mac & " -> " & dst_mac, debug);
        filter_spark(dest_buf, src_buf);
    end;

    procedure log(msg: String; t: log_type) is
        c_msg: String := msg & Character'Val(0);
    begin
        case t is
            when debug => c_log(c_msg'Address);
            when warn => c_warn(c_msg'Address);
            when error => c_error(c_msg'Address);
        end case;
    end;

    procedure hex_dump(value: Buffer; dump: out String) with
        SPARK_Mode is
    begin
        dump := (others => '~');
        for i in 0 .. value'Length - 1 loop
            dump(dump'First + i * 2) := hex(value(value'First + i).lower);
            dump(dump'First + i * 2 + 1) := hex(value(value'First + i).upper);
        end loop;
    end;


    procedure filter_spark (
        dest: out Buffer;
        src: in Buffer) with
        SPARK_Mode is
    begin
        dest := src;
    end;

end baseband_fw;
