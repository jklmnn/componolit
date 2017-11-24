with System;

package Nic_filter is

    procedure filter(
        dest: System.Address;
        src: System.Address;
        dest_size: Integer;
        src_size: Integer
        );

    private

    type char_array is array (integer range <>) of Character;

    procedure filter_spark (
        dest: out char_array;
        src: in char_array) with
        SPARK_Mode,
        Pre => (dest'Length = src'Length),
        Depends => (dest => src);

end Nic_filter;
