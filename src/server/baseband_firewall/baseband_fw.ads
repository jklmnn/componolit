with System;
with Fw_Types;
with Dissector;
use all type Fw_Types.U32;
use all type Fw_Types.U32_Index;
use all type Fw_Types.Direction;
use all type Dissector.Result;

package Baseband_Fw is

    BUFFER_SIZE : constant Fw_Types.U32 := 4096;

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

    subtype Directed_Buffer_Range is Fw_Types.U32_Index range 0 .. BUFFER_SIZE - 1;

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

    procedure Cat (
                   Direction : Fw_Types.Direction;
                   Source    : Fw_Types.Buffer;
                   Size      : Fw_Types.U32
                  )
      with
        Pre => Direction /= Fw_Types.Unknown and then
        Size <= Source'Length and then
        Size > 0 and then
        Packet_Buffer (Direction)'First + Packet_Cursor (Direction).Cat + Size <= Directed_Buffer_Range'Last;

    procedure Disassemble (
                           Source      : Fw_Types.Buffer;
                           Direction   : Fw_Types.Direction;
                           Eth_Header  : out Fw_Types.Eth;
                           Status      : out Dissector.Result
                          )
      with
    Post => (if Direction = Fw_Types.Unknown then Status /= Dissector.Checked);

    procedure Assemble (
                        Eth_Header  : Fw_Types.Eth;
                        Destination : out Fw_Types.Buffer;
                        Direction   : Fw_Types.Direction;
                        Instance    : Fw_Types.Process
                       )
      with
        Pre => Direction /= Fw_Types.Unknown and
        Destination'First + Fw_Types.Eth_Offset + Fw_Types.Sl3p_Offset < Destination'Last;

    procedure Packet_Select_Eth (
                                 Header      : Fw_Types.Eth;
                                 Payload     : Fw_Types.Buffer;
                                 Dir         : Fw_Types.Direction;
                                 Status      : out Dissector.Result
                                )
      with
        Post => (if Dir = Fw_Types.Unknown then Status /= Dissector.Checked);

    procedure Packet_Select_Sl3p (
                                  Packet      : Fw_Types.Buffer;
                                  Dir         : Fw_Types.Direction
                                 )
      with
        Pre => Dir /= Fw_Types.Unknown and Packet'Length <= 1500;

    procedure Packet_Select_RIL (
                                 Packet      : Fw_Types.Buffer;
                                 Dir         : Fw_Types.Direction;
                                 Instance    : Fw_Types.Process;
                                 Destination : out Fw_Types.Buffer;
                                 Eth_Header  : Fw_Types.Eth
                                )
      with
        Pre => Dir /= Fw_Types.Unknown and
        Packet'Length > 0 and
        Destination'Length > Fw_Types.Eth_Offset + Fw_Types.Sl3p_Offset + Packet'Length and
        Destination'First + Fw_Types.Eth_Offset + Fw_Types.Sl3p_Offset + Packet'Length < Destination'Last;

    RIL_Proxy_Ethtype  : constant Fw_Types.U16 := 16#524c#;
    RIL_Proxy_Setup    : constant Fw_Types.U32 := 16#15c70000#;
    RIL_Proxy_Teardown : constant Fw_Types.U32 := 16#17c70000#;

end Baseband_Fw;
