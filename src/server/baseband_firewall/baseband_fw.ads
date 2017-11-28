with System;
with fw_types;

package baseband_fw is

    procedure filter(
        dest: System.Address;
        src: System.Address;
        dest_size: Integer;
        src_size: Integer;
        dir: Integer
        );

    private

    procedure copy (
        dest: out fw_types.Buffer;
        src: in fw_types.Buffer) with
        SPARK_Mode,
        Pre => (dest'Length = src'Length),
        Depends => (dest => src);

    function analyze (
        source: in fw_types.Packet;
        dir: fw_types.Direction) return fw_types.Status with
        SPARK_Mode;

end baseband_fw;
