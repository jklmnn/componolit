with System;
with Fw_Types;
use all type Fw_Types.U32;

package Baseband_Fw is

    BUFFER_SIZE : Fw_Types.U32 := 4096;

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

    type Directed_Sequence is array (Fw_Types.Direction range Fw_Types.BP .. Fw_Types.AP) of Fw_Types.U64;
    Source_Sequence : Directed_Sequence := (others => 0);
    Destination_Sequence : Directed_Sequence := (others => 1);

    subtype Directed_Buffer_Range is Fw_Types.U32 range 0 .. BUFFER_SIZE - 1;

    type Directed_Buffer is array (Fw_Types.Direction range Fw_Types.BP .. Fw_Types.AP)
      of Fw_Types.Buffer (Directed_Buffer_Range);
    Packet_Buffer : Directed_Buffer := (others => (others => 0));

    type Cursor is
        record
            Parse : Directed_Buffer_Range;
            Cat   : Directed_Buffer_Range;
        end record;
    type Directed_Cursor is array (Fw_Types.Direction range Fw_Types.BP .. Fw_Types.AP) of Cursor;
    Packet_Cursor : Directed_Cursor := (others => (others => 0));

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

    procedure Cat (
                   Direction : Fw_Types.Direction;
                   Source    : Fw_Types.Buffer;
                   Size      : Fw_Types.U32
                  );

    procedure Disassemble (
                           Source      : Fw_Types.Buffer;
                           Direction   : Fw_Types.Direction;
                           Eth_Header  : out Fw_Types.Eth
                          );

    procedure Assemble (
                        Eth_Header  : Fw_Types.Eth;
                        Destination : out Fw_Types.Buffer;
                        Direction   : Fw_Types.Direction;
                        Instance    : Fw_Types.Process
                       );

    procedure Packet_Select_Eth (
                                 Header      : Fw_Types.Eth;
                                 Payload     : Fw_Types.Buffer;
                                 Dir         : Fw_Types.Direction
                                );

    procedure Packet_Select_Sl3p (
                                  Packet      : Fw_Types.Buffer;
                                  Dir         : Fw_Types.Direction
                                 );

    procedure Packet_Select_RIL (
                                 Packet      : Fw_Types.Buffer;
                                 Dir         : Fw_Types.Direction;
                                 Instance    : Fw_Types.Process;
                                 Destination : out Fw_Types.Buffer;
                                 Eth_Header  : Fw_Types.Eth
                                );

    RIL_Proxy_Ethtype  : constant Fw_Types.U16 := 16#524c#;
    RIL_Proxy_Setup    : constant Fw_Types.U32 := 16#15c70000#;
    RIL_Proxy_Teardown : constant Fw_Types.U32 := 16#17c70000#;

end Baseband_Fw;
