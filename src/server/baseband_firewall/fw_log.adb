
package body fw_log is

    pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");

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

    function directed_arrow(dir: fw_types.Direction) return Arrow with
        SPARK_Mode is
    begin
        case dir is
            when fw_types.UNKNOWN => return "<>";
            when fw_types.AP => return "<-";
            when fw_types.BP => return "->";
        end case;
    end;

end fw_log;
