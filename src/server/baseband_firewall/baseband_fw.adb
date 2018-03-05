with Genode_Log;
with Fw_Log;
with Fw_Types;
with Dissector;
use all type Fw_Types.U16;
use all type Fw_Types.U64;
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
                      Size     : Fw_Types.U32;
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
                    Src  :        Fw_Types.Buffer
                   )
    is
    begin
        Dest (Dest'First .. Dest'Last) := Src (Src'First .. Src'Last);
    end Copy;

    procedure Disassemble (
                           Source      : Fw_Types.Buffer;
                           Direction   : Fw_Types.Direction;
                           Eth_Header  : out Fw_Types.Eth;
                           Status      : out Dissector.Result
                          )
    is
        Arrow : constant Fw_Log.Arrow := Fw_Log.Directed_Arrow (Direction);
    begin
        Status := Dissector.Unchecked;
        Eth_Header := ((others => 0), (others => 0), 0);
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
                                   Direction,
                                   Status); 
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
        Status     : Dissector.Result;
    begin

        Disassemble (Source_Buffer, Direction, Eth_Header, Status);

        if Eth_Header.Ethtype /= RIL_Proxy_Ethtype then
            Destination_Buffer := (others => 0);
            if Destination_Buffer'Length >= Source_Buffer'Length then
                Destination_Buffer (Destination_Buffer'First .. Destination_Buffer'First + Source_Buffer'Length - 1) := Source_Buffer;
                Submit (Source_Buffer'Length, Instance);
            end if;
        else
            if Status = Dissector.Checked then
                Assemble (Eth_Header, Destination_Buffer, Direction, Instance);
            else
                Genode_Log.Warn ("Dropping packet with unknown direction");
            end if;
        end if;

    end Filter;

    procedure Packet_Select_Eth (
                                 Header  : Fw_Types.Eth;
                                 Payload : Fw_Types.Buffer;
                                 Dir     : Fw_Types.Direction;
                                 Status  : out Dissector.Result
                                )
    is
    begin
        Status := Dissector.Valid (Header, Payload, Dir);
        pragma Assert ((if Dir = Fw_Types.Unknown then Status /= Dissector.Checked));
        if Status = Dissector.Checked then
            if Payload'Length > Fw_Types.Eth_Offset then
                Packet_Select_Sl3p (Payload (Payload'First + Fw_Types.Eth_Offset .. Payload'Last),
                                    Dir);
            end if;
        else
            Genode_Log.Warn ("Invalid ethernet packet: " & Dissector.Image (Status));
        end if;
    end Packet_Select_Eth;

    procedure Packet_Select_Sl3p (
                                  Packet      : Fw_Types.Buffer;
                                  Dir         : Fw_Types.Direction
                                 )
    is
        Header : Fw_Types.Sl3p;
        Status : Dissector.Result;
    begin
        if Packet'Length >= Fw_Types.Sl3p_Offset and
          Packet'First + Fw_Types.Sl3p_Offset < Packet'Last then
            Header := Dissector.Sl3p_Be (Packet);
            Status := Valid (Header,
                            Packet (Packet'First + Fw_Types.Sl3p_Offset .. Packet'Last),
                             Source_Sequence (Dir));
            pragma Assert ((if Status = Dissector.Checked then Packet (Packet'First + Fw_Types.Sl3p_Offset .. Packet'Last)'Length >= Header.Length));
            if Status = Dissector.Checked  and Header.Length > 0 then
                pragma Assert (Packet (Packet'First + Fw_Types.Sl3p_Offset .. Packet'Last)'Length >= Header.Length);
                
                Cat (Dir,
                     Packet (Packet'First + Fw_Types.Sl3p_Offset .. Packet'Last),
                     Header.Length);
                Source_Sequence (Dir) := Header.Sequence_Number;
            else
                Genode_Log.Warn ("Invalid sl3p packet :" & Dissector.Image (Status));
            end if;
        end if;
    end Packet_Select_Sl3p;

    procedure Cat (
                   Direction : Fw_Types.Direction;
                   Source    : Fw_Types.Buffer;
                   Size      : Fw_Types.U32
                  )
    is
        Start : constant Fw_Types.U32 := Packet_Buffer (Direction)'First + Packet_Cursor (Direction).Cat;
    begin
        pragma Assert (Start + Size <= Directed_Buffer_Range'Last);
        Packet_Buffer (Direction) (Start .. Start + Size - 1) :=
          Source (Source'First .. Source'First + Size - 1);
        Packet_Cursor (Direction).Cat := Packet_Cursor (Direction).Cat + Size;
    end Cat;

    procedure Assemble (
                        Eth_Header  : Fw_Types.Eth;
                        Destination : out Fw_Types.Buffer;
                        Direction   : Fw_Types.Direction;
                        Instance    : Fw_Types.Process
                       )
    is
        Header       : Fw_Types.RIL;
        Status       : Dissector.Result;
        Packet_Split : Boolean := False;
    begin
        while Packet_Cursor (Direction).Parse + 12 < Packet_Cursor (Direction).Cat loop

            Header := Dissector.Ril_Be (Packet_Buffer (Direction) (Packet_Cursor (Direction).Parse ..
                                          Packet_Cursor (Direction).Cat));
            Status := Dissector.Valid (Header, Packet_Buffer (Direction) (Packet_Cursor (Direction).Parse +
                                         Fw_Types.RIL_Offset .. Packet_Cursor (Direction).Cat));

            case Status is
                when Dissector.Checked =>

                    Packet_Select_RIL (Packet_Buffer (Direction) (Packet_Cursor (Direction).Parse +
                                         Fw_Types.RIL_Offset ..
                                           Packet_Cursor (Direction).Parse +
                                         Fw_Types.RIL_Offset +
                                           Header.Length - 1),
                                       Direction,
                                       Instance,
                                       Destination,
                                       Eth_Header);

                    if Packet_Cursor (Direction).Parse + Fw_Types.RIL_Offset + Header.Length < Directed_Buffer_Range'Last Then
                        Packet_Cursor (Direction).Parse := Packet_Cursor (Direction).Parse +
                          Fw_Types.RIL_Offset +
                            Header.Length;
                    end if;

                when Dissector.Invalid_Size =>
                    Packet_Split := True;
                when others =>
                    Genode_Log.Warn ("Invalid RIL packet :" & Dissector.Image (Status));
            end case;
        end loop;
        
        if Packet_Split = False then
            Packet_Cursor (Direction) := (others => 0);
        end if;
    end Assemble;

    procedure Packet_Select_RIL (
                                 Packet      : Fw_Types.Buffer;
                                 Dir         : Fw_Types.Direction;
                                 Instance    : Fw_Types.Process;
                                 Destination : out Fw_Types.Buffer;
                                 Eth_Header  : Fw_Types.Eth
                                )
    is
        Sl3p_Header : constant Fw_Types.Sl3p := (Sequence_Number => Destination_Sequence (Dir),
                                                 Length          => Packet'Length);
    begin
        pragma Assert (Destination (Destination'First .. Destination'First + Fw_Types.Eth_Offset - 1)'Length = Fw_Types.Eth_Offset);
        Dissector.Eth_Be (Eth_Header, Destination (Destination'First .. Destination'First + Fw_Types.Eth_Offset - 1));
        pragma Assert (Destination (Destination'First + Fw_Types.Eth_Offset ..
                             Destination'First + Fw_Types.Eth_Offset + Fw_Types.Sl3p_Offset - 1)'Length = Fw_Types.Eth_Offset + Fw_Types.Sl3p_Offset);
        Dissector.Sl3p_Be (Sl3p_Header, Destination (Destination'First + Fw_Types.Eth_Offset ..
                             Destination'First + Fw_Types.Eth_Offset + Fw_Types.Sl3p_Offset - 1));
        Copy (Destination (Destination'First + Fw_Types.Eth_Offset + Fw_Types.Sl3p_Offset ..
                Destination'First + Fw_Types.Eth_Offset + Fw_Types.Sl3p_Offset + Packet'Length - 1),
              Packet);
        Submit (Fw_Types.Eth_Offset + Fw_Types.Sl3p_Offset + Packet'Length, Instance);
        Destination_Sequence (Dir) := Destination_Sequence (Dir) + 1;
    end Packet_Select_RIL;

end Baseband_Fw;