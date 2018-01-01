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

    proto: constant fw_types.Byte := (1,1);
    port: constant fw_types.Port := ((4,9), (14,0));
    ril_length: constant fw_types.Buffer := ((0,0), (0,0), (0,0), (0,4));
    ril_setup: constant fw_types.Buffer := ((1, 5), (12, 7), (0,0), (0,0));
    ril_teardown: constant fw_types.Buffer := ((1, 7), (12, 7), (0,0), (0,0));

end baseband_fw;