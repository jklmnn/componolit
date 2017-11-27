with System;

package baseband_fw is

    procedure filter(
        dest: System.Address;
        src: System.Address;
        dest_size: Integer;
        src_size: Integer
        );

    private

    type char_array is array (integer range <>) of Character;
    type log_type is (debug, warn, error);

    procedure c_log(msg: System.Address) with
        Import,
        Convention => C,
        External_name => "log";

    procedure c_warn(msg: System.Address) with
        Import,
        Convention => C,
        External_name => "warn";

    procedure c_error(msg: System.Address) with
        Import,
        Convention => C,
        External_name => "error";

    procedure log(msg: String; t: log_type) with
        SPARK_Mode,
        Pre => msg'Length < 1024;

    procedure filter_spark (
        dest: out char_array;
        src: in char_array) with
        SPARK_Mode,
        Pre => (dest'Length = src'Length),
        Depends => (dest => src);

end baseband_fw;
