with System;
with fw_types;

package baseband_fw is

    procedure filter(
        dest: System.Address;
        src: System.Address;
        dest_size: Integer;
        src_size: Integer
        );

    private

    procedure filter_spark (
        dest: out fw_types.Buffer;
        src: in fw_types.Buffer) with
        SPARK_Mode,
        Pre => (dest'Length = src'Length),
        Depends => (dest => src);

end baseband_fw;
