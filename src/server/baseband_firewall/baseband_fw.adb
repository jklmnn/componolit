with Fw_Types;
use all type Fw_Types.U16;
use all type Fw_Types.U64;
use all type Fw_Types.Status;

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
        Dest_Buf : Fw_Types.Buffer (0 .. Dest_Size - 1);
        for Dest_Buf'Address use Dest;

        Src_Buf : Fw_Types.Buffer (0 .. Src_Size - 1);
        for Src_Buf'Address use Src;

        Instance : constant Fw_Types.Process := (Firewall, Iface);
    begin
        if Dest_Buf'Length > 1514 then
            Filter (Src_Buf, Dest_Buf (Dest_Buf'First .. Dest_Buf'First + 1513),
                    Fw_Types.Direction'Val (Dir), Instance);
        else
            Filter (Src_Buf, Dest_Buf, Fw_Types.Direction'Val (Dir), Instance);
        end if;
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

    procedure Disassemble (
                           Source      : Fw_Types.Buffer;
                           Direction   : Fw_Types.Direction;
                           Eth_Header  : out Dissector.Eth
                          )
    is
    begin
        Eth_Header := ((others => 0), (others => 0), 0, Unchecked);
        if Source'Length > Dissector.Eth_Offset then
            Eth_Header := Dissector.Eth_Be (Source, Direction);
            if Eth_Header.Ethtype = RIL_Proxy_Ethtype and Eth_Header.Status = Dissector.Checked then
                Packet_Select_Sl3p (Source (Source'First + Dissector.Eth_Offset .. Source'Last),
                                    Direction);
            end if;
        end if;
    end Disassemble;

    procedure Filter (
                      Source_Buffer      : Fw_Types.Buffer;
                      Destination_Buffer : out Eth_Packet;
                      Direction          : Fw_Types.Direction;
                      Instance           : Fw_Types.Process
                     )
    is
        Eth_Header : Dissector.Eth;
    begin
        Destination_Buffer := (others => 0);

        Disassemble (Source_Buffer, Direction, Eth_Header);

        if Eth_Header.Ethtype /= RIL_Proxy_Ethtype then

            if Source_Buffer'Length >= Minimal_Submit_Size and
              Destination_Buffer'Length >= Source_Buffer'Length and Source_Buffer'Length > 0
            then
                Destination_Buffer (Destination_Buffer'First .. Destination_Buffer'First + Source_Buffer'Length - 1) :=
                  Source_Buffer (Source_Buffer'First .. Source_Buffer'Last);
                Submit (Source_Buffer'Length, Instance);
            else
                Genode_Log.Warn ("Invalid external packet dropped, length: " &
                                   Fw_Types.Image (Fw_Types.U32 (Source_Buffer'Length)));
            end if;
        else
            if Eth_Header.Status = Dissector.Checked and
              Destination_Buffer'Length > Dissector.Eth_Offset + Dissector.Sl3p_Offset
            then
                Assemble (Eth_Header, Destination_Buffer, Direction, Instance);
            else
                Genode_Log.Warn ("Invalid ethernet packet: " & Dissector.Image (Eth_Header.Status) & " " &
                                Fw_Types.Image (Fw_Types.U32 (Source_Buffer'Length)));
            end if;
        end if;

    end Filter;

    procedure Packet_Select_Sl3p (
                                  Packet      : Fw_Types.Buffer;
                                  Dir         : Fw_Types.Direction
                                 )
    is
        Header : Dissector.Sl3p;
    begin
        if Packet'Length >= Dissector.Sl3p_Offset then
            Header := Dissector.Sl3p_Be (Packet, Source_Sequence (Dir));
            if Header.Status = Dissector.Checked and Header.Length > 0 then
                if Packet_Buffer (Dir)'First + Packet_Cursor (Dir).Cat + Header.Length <=
                  Directed_Buffer_Range'Last
                then
                    Cat (Dir,
                         Packet (Packet'First + Dissector.Sl3p_Offset .. Packet'Last),
                         Header.Length);
                    Source_Sequence (Dir) := Header.Sequence_Number;
                else
                    Genode_Log.Warn ("Failed to cat packet, buffer to small");
                end if;
            else
                Genode_Log.Warn ("Invalid sl3p packet: " & Dissector.Image (Header.Status));
                Genode_Log.Warn ("Sl3p: " & Fw_Types.Image (Header.Length) & " : " &
                                   Fw_Types.Image (Fw_Types.U32 (Packet'Length)));
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
        pragma Assert (Packet_Buffer (Direction) (Start .. Start + Size - 1)'Length =
                         Source (Source'First .. Source'First + Size - 1)'Length);
        Packet_Buffer (Direction) (Start .. Start + Size - 1) :=
          Source (Source'First .. Source'First + Size - 1);
        Packet_Cursor (Direction).Cat := Packet_Cursor (Direction).Cat + Size;
    end Cat;

    procedure Assemble (
                        Eth_Header  : Dissector.Eth;
                        Destination : in out Eth_Packet;
                        Direction   : Fw_Types.Direction;
                        Instance    : Fw_Types.Process
                       )
    is
        Header       : Dissector.RIL;
        Packet_Split : Boolean := True;
    begin
        while Packet_Cursor (Direction).Parse + 8 <= Packet_Cursor (Direction).Cat loop

            Header := Dissector.Ril_Be (Packet_Buffer (Direction) (Packet_Cursor (Direction).Parse ..
                                          Packet_Cursor (Direction).Cat));

            case Header.Status is
                when Dissector.Checked =>

                    Packet_Split := False;
                    Genode_Log.Log ("RIL: " & Fw_Types.Image (Header.Token_Event));

                    if Packet_Cursor (Direction).Parse + Header.Length + 4 <=
                      Directed_Buffer_Range'Last
                    then
                        Packet_Select_RIL (Packet_Buffer (Direction) (Packet_Cursor (Direction).Parse ..
                                               Packet_Cursor (Direction).Parse +
                                               Header.Length + 3),
                                           Direction,
                                           Instance,
                                           Destination,
                                           Eth_Header);

                        Packet_Cursor (Direction).Parse := Packet_Cursor (Direction).Parse +
                          4 + Header.Length;
                    end if;

                when Dissector.Invalid_Size =>
                    Packet_Split := True;
                    Genode_Log.Warn ("Packet split " & Fw_Types.Image (Header.Length) & " " &
                                       Fw_Types.Image (Fw_Types.U32 (Packet_Buffer (Direction)
                                       (Packet_Cursor (Direction).Parse ..
                                          Packet_Cursor (Direction).Cat)'Length)));
                    exit;
                when others =>
                    Genode_Log.Warn ("Invalid RIL packet :" & Dissector.Image (Header.Status));
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
                                 Destination : in out Eth_Packet;
                                 Eth_Header  : Dissector.Eth
                                )
    is
        Sl3p_Header   : Dissector.Sl3p;
        Packet_Offset : Fw_Types.U32_Index := Packet'First;
        Packet_Size   : Fw_Types.U32;
    begin
        Fragment : loop
            pragma Loop_Invariant (Packet_Offset <= Packet'Last);
            pragma Loop_Invariant (Packet_Offset >= Packet'First);
            Packet_Size := Packet'Last - Packet_Offset + 1;

            Sl3p_Header := (Sequence_Number => Destination_Sequence (Dir),
                            Length          => (if Packet_Size > 1488 then 1488 else Packet_Size),
                            Status          => Dissector.Checked);
            Send_Ethernet_Packet (Packet (Packet_Offset .. Packet_Offset + Sl3p_Header.Length - 1),
                                  Eth_Header, Sl3p_Header, Destination, Instance);
            Destination_Sequence (Dir) := Destination_Sequence (Dir) + 1;
            exit Fragment when Packet_Size < 1488;
            if Packet_Offset + Packet_Size < Packet'Last then
                Packet_Offset := Packet_Offset + Packet_Size;
            end if;
        end loop Fragment;
    end Packet_Select_RIL;

    procedure Send_Ethernet_Packet (
                                    Payload     : Fw_Types.Buffer;
                                    Eth_Header  : Dissector.Eth;
                                    Sl3p_Header : Dissector.Sl3p;
                                    Destination : in out Eth_Packet;
                                    Instance    : Fw_Types.Process
                                   )
    is
        Local_Offset : Fw_Types.U32_Index := Destination'First;
        Size : Fw_Types.U32 := Dissector.Eth_Offset + Dissector.Sl3p_Offset + Payload'Length;
    begin
        Dissector.Eth_Be (Eth_Header, Destination (Local_Offset .. Local_Offset + Dissector.Eth_Offset - 1));
        Local_Offset := Local_Offset + Dissector.Eth_Offset;
        Dissector.Sl3p_Be (Sl3p_Header, Destination (Local_Offset .. Local_Offset + Dissector.Sl3p_Offset - 1));
        Local_Offset := Local_Offset + Dissector.Sl3p_Offset;
        Destination (Local_Offset .. Local_Offset + Payload'Length - 1) := Payload;
        if Size < Minimal_Submit_Size then
            Size := Minimal_Submit_Size;
        end if;
        Submit (Size, Instance);
    end Send_Ethernet_Packet;

end Baseband_Fw;
