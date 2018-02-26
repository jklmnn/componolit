with System;
with Fw_Types;
use all type Fw_Types.U32;

package Baseband_Fw is

    procedure Filter_Hook (
                          Dest      : System.Address;
                          Src       : System.Address;
                          Dest_Size : Fw_Types.U32;
                          Src_Size  : Fw_Types.U32;
                          Dir       : Integer;
                          Firewall  : System.Address;
                          Iface     : Integer
                         );

    procedure Submit (
                      Size : Fw_Types.U32;
                      Instance : Fw_Types.Process
                     );

private

    procedure Filter (
                      Source_Buffer      :        Fw_Types.Buffer;
                      Destination_Buffer :    out Fw_Types.Buffer;
                      Direction          :        Fw_Types.Direction;
                      Instance           : Fw_Types.Process
                     );

    procedure Copy (
                    Dest :    out Fw_Types.Buffer;
                    Src  :        Fw_Types.Buffer;
                    Size : Fw_Types.U32
                   )
    with
       Pre     => (Size <= Dest'Length and Size <= Src'Length),
       Depends => (Dest => (Src, Size));

    procedure Packet_Select_Eth (
                                 Header      : Fw_Types.Eth;
                                 Payload     : Fw_Types.Buffer;
                                 Dir         : Fw_Types.Direction;
                                 Instance    : Fw_Types.Process;
                                 Destination : out Fw_Types.Buffer
                                );

--      procedure Packet_Select_Sl3p (
--                                    Packet      : Fw_Types.Buffer;
--                                    Dir         : Fw_Types.Direction;
--                                    Instance    : Fw_Types.Process;
--                                    Destination : Fw_Types.Buffer
--                                   );
--
--      procedure Packet_Select_RIL (
--                                   Packet      : Fw_Types.Buffer;
--                                   Dir         : Fw_Types.Direction;
--                                   Instance    : Fw_Types.Process;
--                                   Destination : Fw_Types.Buffer
--                                  );

    RIL_Proxy_Ethtype  : constant Fw_Types.U16 := 16#524c#;
    RIL_Proxy_Setup    : constant Fw_Types.U32 := 16#15c70000#;
    RIL_Proxy_Teardown : constant Fw_Types.U32 := 16#17c70000#;

    type Directed_Sequence is array (Fw_Types.Direction range Fw_Types.BP .. Fw_Types.AP) of Fw_Types.U64;
    Sequence : Directed_Sequence := (others => 0);

end Baseband_Fw;
