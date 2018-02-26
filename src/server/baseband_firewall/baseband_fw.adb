with Genode_Log;
with Fw_Log;
with Fw_Types;
with Dissector;
use all type Fw_Types.U16;
use all type Fw_Types.U32;
use all type Fw_Types.Direction;
use all type Fw_Types.Status;
use all type Dissector.Result;

package body Baseband_Fw
is

    pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");

    function Filter_Hook (
                           Dest      : System.Address;
                           Src       : System.Address;
                           Dest_Size : Fw_Types.U32;
                           Src_Size  : Fw_Types.U32;
                           Dir       : Integer
                          ) return Integer
      with
        SPARK_Mode => Off
    is
        Dest_Buf : Fw_Types.Buffer (0 .. Dest_Size);
        for Dest_Buf'Address use Dest;

        Src_Buf : Fw_Types.Buffer (0 .. Src_Size);
        for Src_Buf'Address use Src;

        Ready : Integer;
    begin
        Filter (Src_Buf, Dest_Buf, Fw_Types.Direction'Val (Dir), Ready);
        return Ready;
    end Filter_Hook;

    procedure Copy (
                    Dest :    out Fw_Types.Buffer;
                    Src  :        Fw_Types.Buffer
                   )
    is
    begin
        Dest := Src;
    end Copy;

    procedure Analyze (
                       Source :        Fw_Types.Buffer;
                       Dir    :        Fw_Types.Direction;
                       Result :    out Fw_Types.Status
                      )
    is
        Arrow  : constant Fw_Log.Arrow := Fw_Log.Directed_Arrow (Dir);
        Source_Eth : constant Fw_Types.Eth := Dissector.Eth_Be (Source);
        Source_Sl3p : Fw_Types.Sl3p;
        Status : Dissector.Result;
        --  Msg    : Fw_Types.U32;
    begin

        Result := Fw_Types.Accepted;
        if Source_Eth.Ethtype = RIL_Proxy_Ethtype then
            Genode_Log.Log ("(" & Fw_Types.Image (Source_Eth.Ethtype) & ") "
                            & Arrow & " "
                            & Fw_Types.Image (Source_Eth.Source.OUI_0) & ":"
                            & Fw_Types.Image (Source_Eth.Source.OUI_1) & ":"
                            & Fw_Types.Image (Source_Eth.Source.OUI_2) & ":"
                            & Fw_Types.Image (Source_Eth.Source.NIC_0) & ":"
                            & Fw_Types.Image (Source_Eth.Source.NIC_1) & ":"
                            & Fw_Types.Image (Source_Eth.Source.NIC_2)
                           );
            Status := Dissector.Valid (Source_Eth, Source, Dir);
            if Status /= Dissector.Checked then
                Genode_Log.Log ("Invalid packet: " & Dissector.Image (Status));
                Result := Fw_Types.Rejected;
            else
                Source_Sl3p := Dissector.Sl3p_Be (Source (Source'First +
                                                    Fw_Types.Eth_Offset .. Source'Last));
                Status := Dissector.Valid (Source_Sl3p,
                                           Source (Source'First +
                                               Fw_Types.Eth_Offset +
                                                 Fw_Types.Sl3p_Offset .. Source'Last),
                                           Sequence (Dir));
            end if;
        end if;

            --              Msg := Source.RIL_Header.ID;
            --              Result := Accepted;
            --
            --              Genode_Log.Log (Fw_Types.Image (Msg + 1));
            --              Genode_Log.Log (Fw_Types.Image (Source.RIL_Header.Length + 5));
            --              Genode_Log.Log (Fw_Types.Image (Fw_Types.U32'(16#abcd0123#)));
            --              Genode_Log.Log (Fw_Types.Image (Fw_Types.U32'(1)));
            --
            --              if Msg = RIL_Proxy_Setup then
            --                  Genode_Log.Log (Arrow & " SETUP");
            --              elsif Msg = RIL_Proxy_Teardown then
            --                  Genode_Log.Log (Arrow & " TEARDOWN");
            --              else
            --                  Genode_Log.Log (Arrow &
            --                                    " UNKNOWN: " &
            --                                    Fw_Types.Image (Source.RIL_Header.ID) &
            --                                    " TOKEN: " &
            --                                    Fw_Types.Image (Source.RIL_Header.Token_Event));
            --              end if;
    end Analyze;

    --  FIXME: We should do the conversion from Packet -> Buffer in SPARK!
    procedure Filter (
                      Source_Buffer      :        Fw_Types.Buffer;
                      Destination_Buffer :    out Fw_Types.Buffer;
                      Direction          :        Fw_Types.Direction;
                      Ready              : out Integer
                     )
    is
        Packet_Status : Fw_Types.Status;
    begin
        Analyze (Source_Buffer, Direction, Packet_Status);
        case Packet_Status
        is
            when Fw_Types.Accepted =>
                Copy (Src => Source_Buffer, Dest => Destination_Buffer);
                Ready := 1;
            when Fw_Types.Rejected =>
                --  Copy (Src => Source_Buffer, Dest => Destination_Buffer);
                Ready := 0;
        end case;
    end Filter;

end Baseband_Fw;
