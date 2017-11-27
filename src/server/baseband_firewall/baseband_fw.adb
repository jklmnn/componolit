
package body baseband_fw is

    procedure filter(
        dest: System.Address;
        src: System.Address;
        dest_size: Integer;
        src_size: Integer) 
    is
        dest_buf: char_array (0 .. dest_size);
        src_buf: char_array (0 .. src_size);
        for dest_buf'Address use dest;
        for src_buf'Address use src;
    begin
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

    procedure filter_spark (
        dest: out char_array;
        src: in char_array) with
        SPARK_Mode is
    begin
        log("log", debug);
        log("warning", warn);
        log("error", error);
        dest := src;
    end;

end baseband_fw;
