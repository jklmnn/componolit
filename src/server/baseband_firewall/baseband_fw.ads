with System;
with Fw_Types;

package Baseband_Fw is

    function Filter_Hook (
                           Dest      : System.Address;
                           Src       : System.Address;
                           Dest_Size : Fw_Types.U32;
                           Src_Size  : Fw_Types.U32;
                           Dir       : Integer
                          ) return Integer;

private

    procedure Filter (
                      Source_Buffer      :        Fw_Types.Buffer;
                      Destination_Buffer :    out Fw_Types.Buffer;
                      Direction          :        Fw_Types.Direction;
                      Ready              : out Integer
                     );

    procedure Copy (
                    Dest :    out Fw_Types.Buffer;
                    Src  :        Fw_Types.Buffer
                   )
    with
       Pre     => (Dest'Length = Src'Length),
       Depends => (Dest => Src);

    procedure Analyze
      (Source :        Fw_Types.Packet;
       Dir    :        Fw_Types.Direction;
       Result :    out Fw_Types.Status);

    RIL_Proxy_Ethtype  : constant Fw_Types.U16 := 16#524c#;
    RIL_Proxy_Setup    : constant Fw_Types.U32 := 16#15c70000#;
    RIL_Proxy_Teardown : constant Fw_Types.U32 := 16#17c70000#;

end Baseband_Fw;
