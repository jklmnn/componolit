
package body Nic_filter is

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

    procedure filter_spark (
        dest: out char_array;
        src: in char_array) with
        SPARK_Mode
    is
    begin
        dest := src;
    end;

end Nic_filter;
