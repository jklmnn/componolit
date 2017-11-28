package body fw_log is

    procedure log(msg: String; t: log_type) is
        c_msg: String := msg & Character'Val(0);
    begin
        case t is
            when debug => c_log(c_msg'Address);
            when warn => c_warn(c_msg'Address);
            when error => c_error(c_msg'Address);
        end case;
    end;

    procedure hex_dump(value: fw_types.Buffer; dump: out String) with
        SPARK_Mode is
    begin
        dump := (others => '~');
        for i in 0 .. value'Length - 1 loop
            dump(dump'First + i * 2) := hex(value(value'First + i).lower);
            dump(dump'First + i * 2 + 1) := hex(value(value'First + i).upper);
        end loop;
    end;

end fw_log;
