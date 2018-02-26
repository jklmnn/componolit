with Genode_Log;
with Fw_Log;
with Fw_Types;
with Dissector;
use all type Fw_Types.U16;
use all type Fw_Types.Direction;
use all type Fw_Types.Status;
use all type Dissector.Result;

package body Baseband_Fw
is

    pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");

    procedure Filter_Hook (
                           Dest      : System.Address;
                           Src       : System.Address;
                           Dest_Size : Fw_Types.U32;
                           Src_Size  : Fw_Types.U32;
                           Dir       : Integer;
                           Firewall  : System.Address;
                           Iface     : Integer
                          )
      with
        SPARK_Mode => Off
    is
        Dest_Buf : Fw_Types.Buffer (0 .. Dest_Size);
        for Dest_Buf'Address use Dest;

        Src_Buf : Fw_Types.Buffer (0 .. Src_Size);
        for Src_Buf'Address use Src;

        Instance : constant Fw_Types.Process := (Firewall, Iface);
    begin
        Filter (Src_Buf, Dest_Buf, Fw_Types.Direction'Val (Dir), Instance);
    end Filter_Hook;

    procedure Submit (
                      Size : Fw_Types.U32;
                      Instance : Fw_Types.Process
                     )
      with
        SPARK_Mode => Off
    is
        procedure C_Submit (
                            Firewall : System.Address;
                            S        : Fw_Types.U32;
                            Iface    : Integer
                           )
          with
            Import,
            Convention => C,
            External_Name => "submit";
    begin
        C_Submit (Instance.Instance, Size, Instance.NIC);
    end Submit;

    procedure Copy (
                    Dest :    out Fw_Types.Buffer;
                    Src  :        Fw_Types.Buffer;
                    Size : Fw_Types.U32
                   )
    is
    begin
        Dest (Dest'First .. Dest'First + Size - 1) := Src (Src'First .. Src'First + Size - 1);
    end Copy;

    procedure Disassemble (
                           Source      : Fw_Types.Buffer;
                           Direction   : Fw_Types.Direction;
                           Eth_Header  : out Fw_Types.Eth
                          )
    is
        Arrow : constant Fw_Log.Arrow := Fw_Log.Directed_Arrow (Direction);
    begin
        if Source'Length >= Fw_Types.Eth_Offset then
            Eth_Header := Dissector.Eth_Be (Source);
            if Eth_Header.Ethtype = RIL_Proxy_Ethtype then
                Genode_Log.Log ("(" & Fw_Types.Image (Eth_Header.Ethtype) & ") "
                                & Arrow & " "
                                & Fw_Types.Image (Eth_Header.Source.OUI_0) & ":"
                                & Fw_Types.Image (Eth_Header.Source.OUI_1) & ":"
                                & Fw_Types.Image (Eth_Header.Source.OUI_2) & ":"
                                & Fw_Types.Image (Eth_Header.Source.NIC_0) & ":"
                                & Fw_Types.Image (Eth_Header.Source.NIC_1) & ":"
                                & Fw_Types.Image (Eth_Header.Source.NIC_2)
                               );
                Packet_Select_Eth (Eth_Header,
                                   Source,
                                   Direction);
            end if;
        end if;
    end Disassemble;
    
    --  FIXME: We should do the conversion from Packet -> Buffer in SPARK!
    procedure Filter (
                      Source_Buffer      : Fw_Types.Buffer;
                      Destination_Buffer : out Fw_Types.Buffer;
                      Direction          : Fw_Types.Direction;
                      Instance           : Fw_Types.Process
                     )
    is
        Eth_Header : Fw_Types.Eth;
    begin
        
        Disassemble(Source_Buffer, Direction, Eth_Header);
        
        if Eth_Header.Ethtype /= RIL_Proxy_Ethtype then
            Copy (Destination_Buffer, Source_Buffer, Source_Buffer'Length);
            Submit (Source_Buffer'Length, Instance);
        end if;
        
        Assemble (Eth_Header, Destination_Buffer, Direction, Instance);
                    
    end Filter;

    procedure Packet_Select_Eth (
                                 Header      : Fw_Types.Eth;
                                 Payload     : Fw_Types.Buffer;
                                 Dir         : Fw_Types.Direction
                                )
    is
        Status : constant Dissector.Result := Dissector.Valid (Header, Payload, Dir);
    begin
        if Status = Dissector.Checked then
            if Payload'Length > Fw_Types.Eth_Offset then
                Packet_Select_Sl3p (Payload (Payload'First + Fw_Types.Eth_Offset .. Payload'Last),
                                    Dir);
            end if;
        else
            Genode_Log.Log ("Invalid packet: " & Dissector.Image (Status));
        end if;
    end Packet_Select_Eth;
    
    procedure Packet_Select_Sl3p (
                                  Packet      : Fw_Types.Buffer;
                                  Dir         : Fw_Types.Direction
                                 )
    is
        Header : Fw_Types.Sl3p;
    begin
        if Packet'Length >= Fw_Types.Sl3p_Offset then
            Header := Dissector.Sl3p_Be (Packet);
        end if;
    end Packet_Select_Sl3p;
    
end Baseband_Fw;
