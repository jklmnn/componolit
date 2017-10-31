
package body Nic_filter is

    procedure test(Num: Integer) is
    begin
        log(Num);
    end;

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
        for I in dest_buf'First .. dest_buf'Last loop
            dest_buf(I) := src_buf(I);
        end loop;
    end;
    
end Nic_filter;
