with System;
with Fw_Types;

package Baseband_Fw is

    procedure Filter_Hook
      (Dest      : System.Address;
       Src       : System.Address;
       Dest_Size : Integer;
       Src_Size  : Integer;
       Dir       : Integer);

private

    procedure Filter
        (Source_Buffer      :        Fw_Types.Buffer;
         Source_Packet      :        Fw_Types.Packet;
         Destination_Buffer :    out Fw_Types.Buffer;
         Direction          :        Fw_Types.Direction);

    procedure Copy
      (Dest :    out Fw_Types.Buffer;
       Src  :        Fw_Types.Buffer)
    with
       Pre     => (Dest'Length = Src'Length),
       Depends => (Dest => Src);

    procedure Analyze
      (Source :        Fw_Types.Packet;
       Dir    :        Fw_Types.Direction;
       Result :    out Fw_Types.Status);

    RIL_Proxy_Proto    : constant Fw_Types.Byte   := 16#11#;
    RIL_Proxy_Port     : constant Fw_Types.Port   := (16#49#, 16#E0#);
    RIL_Proxy_Setup    : constant Fw_Types.Buffer := (16#15#, 16#C7#, 16#00#, 16#00#);
    RIL_Proxy_Teardown : constant Fw_Types.Buffer := (16#17#, 16#C7#, 16#00#, 16#00#);

end Baseband_Fw;
