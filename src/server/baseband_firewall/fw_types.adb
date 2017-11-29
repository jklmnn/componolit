package body fw_types with SPARK_Mode
is

   ---------------
   -- int_value --
   ---------------

    pragma Assert(int_value(Byte'(0,1)) = 1);
    pragma Assert(int_value(Byte'(1,0)) = 16);
    pragma Assert(int_Value(Byte'(1,1)) = 17);

    function exp(base: U32; exp: U32) return U32
    is
        ret: U32 := 1;
    begin
        for i in 1 .. exp loop
            ret := ret * base;
        end loop;
        return ret;
    end;

   function int_value (b: Buffer) return U32
    is
        value : U32 := 0;
    begin
        for i in 0 .. b'Length - 1 loop
            value := value + (int_value(b(i + b'First)) * exp(255, U32(i)));
        end loop;
        return value;
    end int_value;

    pragma Assert(int_value(Buffer'((0,1), (0,0), (0,0), (0,0))) = 1);

end fw_types;
