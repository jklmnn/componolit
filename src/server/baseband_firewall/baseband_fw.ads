with System;
with Fw_Types;

package Baseband_Fw is

    procedure Filter
      (Dest      : System.Address;
       Src       : System.Address;
       Dest_Size : Integer;
       Src_Size  : Integer;
       Dir       : Integer);

private

    procedure Copy
      (Dest :    out Fw_Types.Buffer;
       Src  :        Fw_Types.Buffer)
    with
       SPARK_Mode,
       Pre     => (Dest'Length = Src'Length),
       Depends => (Dest => Src);

    function Analyze
      (Source : Fw_Types.Packet;
       Dir    : Fw_Types.Direction) return Fw_Types.Status
    with
      SPARK_Mode;

    Proto        : constant Fw_Types.Byte   := (1, 1);
    Port         : constant Fw_Types.Port   := ((4, 9), (14, 0));
    RIL_Length   : constant Fw_Types.Buffer := ((0, 0), (0, 0), (0, 0), (0, 4));
    RIL_Setup    : constant Fw_Types.Buffer := ((1, 5), (12, 7), (0, 0), (0, 0));
    RIL_Teardown : constant Fw_Types.Buffer := ((1, 7), (12, 7), (0, 0), (0, 0));

end Baseband_Fw;
