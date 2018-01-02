with Fw_Log;
with Fw_Types;
use all type Fw_Types.Nibble;
use all type Fw_Types.Byte;
use all type Fw_Types.Buffer;
use all type Fw_Types.Direction;
use all type Fw_Types.Status;

package body Baseband_Fw
is

pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");

    procedure Filter
      (Dest      : System.Address;
       Src       : System.Address;
       Dest_Size : Integer;
       Src_Size  : Integer;
       Dir       : Integer)
    is
        Dest_Buf : Fw_Types.Buffer (0 .. Dest_Size);
        for Dest_Buf'Address use Dest;

        Src_Buf : Fw_Types.Buffer (0 .. Src_Size);
        for Src_Buf'Address use Src;

        Src_Packet : Fw_Types.Packet;
        for Src_Packet'Address use Src;

        Packet_Status : constant Fw_Types.Status := Analyze (Src_Packet, Fw_Types.Direction'Val (Dir));
    begin
        if Packet_Status = Fw_Types.Accepted
        then
            Copy (Dest_Buf, Src_Buf);
        else
            Fw_Log.Log ("Dropping packet");
        end if;
    end Filter;

    procedure Copy
      (Dest :    out Fw_Types.Buffer;
       Src  :        Fw_Types.Buffer)
    with
        SPARK_Mode
    is
    begin
        Dest := Src;
    end Copy;

    function Analyze
      (Source : Fw_Types.Packet;
       Dir    : Fw_Types.Direction) return Fw_Types.Status
    with
        SPARK_Mode
    is
        Arrow  : constant Fw_Log.Arrow := Fw_Log.Directed_Arrow (Dir);
        RIL_ID : String (1 .. 8);
        Token  : String (1 .. 8);
        Msg    : Fw_Types.Buffer (0 .. 3);
    begin
        if Source.IP_Header.Protocol /= RIL_Proxy_Proto then
            return Fw_Types.Rejected;
        end if;

        if Source.UDP_Header.Source /= RIL_Proxy_Port or Source.UDP_Header.Destination = RIL_Proxy_Port
        then
            return Fw_Types.Rejected;
        end if;

        if Source.RIL_Packet.Length = RIL_Proxy_Length then
            if Source.RIL_Packet.ID = RIL_Proxy_Setup then
                Fw_Log.Log (Arrow & " SETUP");
                return Fw_Types.Accepted;
            elsif Source.RIL_Packet.ID = RIL_Proxy_Teardown then
                Fw_Log.Log (Arrow & " TEARDOWN");
                return Fw_Types.Accepted;
            end if;
        end if;

        Msg := Source.RIL_Packet.ID;
        if Msg = Fw_Types.Buffer'((0, 1), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GET_SIM_STATUS");
        elsif Msg = Fw_Types.Buffer'((0, 2), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_ENTER_SIM_PIN");
        elsif Msg = Fw_Types.Buffer'((0, 3), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_ENTER_SIM_PUK");
        elsif Msg = Fw_Types.Buffer'((0, 4), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_ENTER_SIM_PIN2");
        elsif Msg = Fw_Types.Buffer'((0, 5), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_ENTER_SIM_PUK2");
        elsif Msg = Fw_Types.Buffer'((0, 6), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CHANGE_SIM_PIN");
        elsif Msg = Fw_Types.Buffer'((0, 7), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CHANGE_SIM_PIN2");
        elsif Msg = Fw_Types.Buffer'((0, 8), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_ENTER_NETWORK_DEPERSONALIZATION");
        elsif Msg = Fw_Types.Buffer'((0, 9), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GET_CURRENT_CALLS");
        elsif Msg = Fw_Types.Buffer'((0, 10), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_DIAL");
        elsif Msg = Fw_Types.Buffer'((0, 11), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GET_IMSI");
        elsif Msg = Fw_Types.Buffer'((0, 12), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_HANGUP");
        elsif Msg = Fw_Types.Buffer'((0, 13), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_HANGUP_WAITING_OR_BACKGROUND");
        elsif Msg = Fw_Types.Buffer'((0, 14), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_HANGUP_FOREGROUND_RESUME_BACKGROUND");
        elsif Msg = Fw_Types.Buffer'((0, 15), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SWITCH_WAITING_OR_HOLDING_AND_ACTIVE");
        elsif Msg = Fw_Types.Buffer'((0, 15), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SWITCH_HOLDING_AND_ACTIVE");
        elsif Msg = Fw_Types.Buffer'((1, 0), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CONFERENCE");
        elsif Msg = Fw_Types.Buffer'((1, 1), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_UDUB");
        elsif Msg = Fw_Types.Buffer'((1, 2), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_LAST_CALL_FAIL_CAUSE");
        elsif Msg = Fw_Types.Buffer'((1, 3), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SIGNAL_STRENGTH");
        elsif Msg = Fw_Types.Buffer'((1, 4), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_VOICE_REGISTRATION_STATE");
        elsif Msg = Fw_Types.Buffer'((1, 5), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_DATA_REGISTRATION_STATE");
        elsif Msg = Fw_Types.Buffer'((1, 6), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_OPERATOR");
        elsif Msg = Fw_Types.Buffer'((1, 7), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_RADIO_POWER");
        elsif Msg = Fw_Types.Buffer'((1, 8), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_DTMF");
        elsif Msg = Fw_Types.Buffer'((1, 9), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SEND_SMS");
        elsif Msg = Fw_Types.Buffer'((1, 10), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SEND_SMS_EXPECT_MORE");
        elsif Msg = Fw_Types.Buffer'((1, 11), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SETUP_DATA_CALL");
        elsif Msg = Fw_Types.Buffer'((1, 12), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SIM_IO");
        elsif Msg = Fw_Types.Buffer'((1, 13), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SEND_USSD");
        elsif Msg = Fw_Types.Buffer'((1, 14), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CANCEL_USSD");
        elsif Msg = Fw_Types.Buffer'((1, 15), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GET_CLIR");
        elsif Msg = Fw_Types.Buffer'((2, 0), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_CLIR");
        elsif Msg = Fw_Types.Buffer'((2, 1), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_QUERY_CALL_FORWARD_STATUS");
        elsif Msg = Fw_Types.Buffer'((2, 2), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_CALL_FORWARD");
        elsif Msg = Fw_Types.Buffer'((2, 3), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_QUERY_CALL_WAITING");
        elsif Msg = Fw_Types.Buffer'((2, 4), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_CALL_WAITING");
        elsif Msg = Fw_Types.Buffer'((2, 5), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SMS_ACKNOWLEDGE");
        elsif Msg = Fw_Types.Buffer'((2, 6), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GET_IMEI");
        elsif Msg = Fw_Types.Buffer'((2, 7), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GET_IMEISV");
        elsif Msg = Fw_Types.Buffer'((2, 8), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_ANSWER");
        elsif Msg = Fw_Types.Buffer'((2, 9), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_DEACTIVATE_DATA_CALL");
        elsif Msg = Fw_Types.Buffer'((2, 10), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_QUERY_FACILITY_LOCK");
        elsif Msg = Fw_Types.Buffer'((2, 11), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_FACILITY_LOCK");
        elsif Msg = Fw_Types.Buffer'((2, 12), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CHANGE_BARRING_PASSWORD");
        elsif Msg = Fw_Types.Buffer'((2, 13), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_QUERY_NETWORK_SELECTION_MODE");
        elsif Msg = Fw_Types.Buffer'((2, 14), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_NETWORK_SELECTION_AUTOMATIC");
        elsif Msg = Fw_Types.Buffer'((2, 15), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_NETWORK_SELECTION_MANUAL");
        elsif Msg = Fw_Types.Buffer'((3, 0), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_QUERY_AVAILABLE_NETWORKS");
        elsif Msg = Fw_Types.Buffer'((3, 1), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_DTMF_START");
        elsif Msg = Fw_Types.Buffer'((3, 2), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_DTMF_STOP");
        elsif Msg = Fw_Types.Buffer'((3, 3), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_BASEBAND_VERSION");
        elsif Msg = Fw_Types.Buffer'((3, 4), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SEPARATE_CONNECTION");
        elsif Msg = Fw_Types.Buffer'((3, 5), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_MUTE");
        elsif Msg = Fw_Types.Buffer'((3, 6), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GET_MUTE");
        elsif Msg = Fw_Types.Buffer'((3, 7), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_QUERY_CLIP");
        elsif Msg = Fw_Types.Buffer'((3, 8), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_LAST_DATA_CALL_FAIL_CAUSE");
        elsif Msg = Fw_Types.Buffer'((3, 9), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_DATA_CALL_LIST");
        elsif Msg = Fw_Types.Buffer'((3, 10), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_RESET_RADIO");
        elsif Msg = Fw_Types.Buffer'((3, 11), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_OEM_HOOK_RAW");
        elsif Msg = Fw_Types.Buffer'((3, 12), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_OEM_HOOK_STRINGS");
        elsif Msg = Fw_Types.Buffer'((3, 13), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SCREEN_STATE");
        elsif Msg = Fw_Types.Buffer'((3, 14), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_SUPP_SVC_NOTIFICATION");
        elsif Msg = Fw_Types.Buffer'((3, 15), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_WRITE_SMS_TO_SIM");
        elsif Msg = Fw_Types.Buffer'((4, 0), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_DELETE_SMS_ON_SIM");
        elsif Msg = Fw_Types.Buffer'((4, 1), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_BAND_MODE");
        elsif Msg = Fw_Types.Buffer'((4, 2), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_QUERY_AVAILABLE_BAND_MODE");
        elsif Msg = Fw_Types.Buffer'((4, 3), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_STK_GET_PROFILE");
        elsif Msg = Fw_Types.Buffer'((4, 4), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_STK_SET_PROFILE");
        elsif Msg = Fw_Types.Buffer'((4, 5), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_STK_SEND_ENVELOPE_COMMAND");
        elsif Msg = Fw_Types.Buffer'((4, 6), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_STK_SEND_TERMINAL_RESPONSE");
        elsif Msg = Fw_Types.Buffer'((4, 7), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_STK_HANDLE_CALL_SETUP_REQUESTED_FROM_SIM");
        elsif Msg = Fw_Types.Buffer'((4, 8), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_EXPLICIT_CALL_TRANSFER");
        elsif Msg = Fw_Types.Buffer'((4, 9), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_PREFERRED_NETWORK_TYPE");
        elsif Msg = Fw_Types.Buffer'((4, 10), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GET_PREFERRED_NETWORK_TYPE");
        elsif Msg = Fw_Types.Buffer'((4, 11), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GET_NEIGHBORING_CELL_IDS");
        elsif Msg = Fw_Types.Buffer'((4, 12), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_LOCATION_UPDATES");
        elsif Msg = Fw_Types.Buffer'((4, 13), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CDMA_SET_SUBSCRIPTION_SOURCE");
        elsif Msg = Fw_Types.Buffer'((4, 14), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CDMA_SET_ROAMING_PREFERENCE");
        elsif Msg = Fw_Types.Buffer'((4, 15), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CDMA_QUERY_ROAMING_PREFERENCE");
        elsif Msg = Fw_Types.Buffer'((5, 0), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_TTY_MODE");
        elsif Msg = Fw_Types.Buffer'((5, 1), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_QUERY_TTY_MODE");
        elsif Msg = Fw_Types.Buffer'((5, 2), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CDMA_SET_PREFERRED_VOICE_PRIVACY_MODE");
        elsif Msg = Fw_Types.Buffer'((5, 3), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CDMA_QUERY_PREFERRED_VOICE_PRIVACY_MODE");
        elsif Msg = Fw_Types.Buffer'((5, 4), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CDMA_FLASH");
        elsif Msg = Fw_Types.Buffer'((5, 5), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CDMA_BURST_DTMF");
        elsif Msg = Fw_Types.Buffer'((5, 6), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CDMA_VALIDATE_AND_WRITE_AKEY");
        elsif Msg = Fw_Types.Buffer'((5, 7), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CDMA_SEND_SMS");
        elsif Msg = Fw_Types.Buffer'((5, 8), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CDMA_SMS_ACKNOWLEDGE");
        elsif Msg = Fw_Types.Buffer'((5, 9), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GSM_GET_BROADCAST_SMS_CONFIG");
        elsif Msg = Fw_Types.Buffer'((5, 10), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GSM_SET_BROADCAST_SMS_CONFIG");
        elsif Msg = Fw_Types.Buffer'((5, 11), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GSM_SMS_BROADCAST_ACTIVATION");
        elsif Msg = Fw_Types.Buffer'((5, 12), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CDMA_GET_BROADCAST_SMS_CONFIG");
        elsif Msg = Fw_Types.Buffer'((5, 13), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CDMA_SET_BROADCAST_SMS_CONFIG");
        elsif Msg = Fw_Types.Buffer'((5, 14), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CDMA_SMS_BROADCAST_ACTIVATION");
        elsif Msg = Fw_Types.Buffer'((5, 15), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CDMA_SUBSCRIPTION");
        elsif Msg = Fw_Types.Buffer'((6, 0), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CDMA_WRITE_SMS_TO_RUIM");
        elsif Msg = Fw_Types.Buffer'((6, 1), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CDMA_DELETE_SMS_ON_RUIM");
        elsif Msg = Fw_Types.Buffer'((6, 2), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_DEVICE_IDENTITY");
        elsif Msg = Fw_Types.Buffer'((6, 3), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_EXIT_EMERGENCY_CALLBACK_MODE");
        elsif Msg = Fw_Types.Buffer'((6, 4), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GET_SMSC_ADDRESS");
        elsif Msg = Fw_Types.Buffer'((6, 5), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_SMSC_ADDRESS");
        elsif Msg = Fw_Types.Buffer'((6, 6), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_REPORT_SMS_MEMORY_STATUS");
        elsif Msg = Fw_Types.Buffer'((6, 7), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_REPORT_STK_SERVICE_IS_RUNNING");
        elsif Msg = Fw_Types.Buffer'((6, 8), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_CDMA_GET_SUBSCRIPTION_SOURCE");
        elsif Msg = Fw_Types.Buffer'((6, 9), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_ISIM_AUTHENTICATION");
        elsif Msg = Fw_Types.Buffer'((6, 10), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_ACKNOWLEDGE_INCOMING_GSM_SMS_WITH_PDU");
        elsif Msg = Fw_Types.Buffer'((6, 11), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_STK_SEND_ENVELOPE_WITH_STATUS");
        elsif Msg = Fw_Types.Buffer'((6, 12), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_VOICE_RADIO_TECH");
        elsif Msg = Fw_Types.Buffer'((6, 13), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GET_CELL_INFO_LIST");
        elsif Msg = Fw_Types.Buffer'((6, 14), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_UNSOL_CELL_INFO_LIST_RATE");
        elsif Msg = Fw_Types.Buffer'((6, 15), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_INITIAL_ATTACH_APN");
        elsif Msg = Fw_Types.Buffer'((7, 0), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_IMS_REGISTRATION_STATE");
        elsif Msg = Fw_Types.Buffer'((7, 1), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_IMS_SEND_SMS");
        elsif Msg = Fw_Types.Buffer'((7, 2), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SIM_TRANSMIT_APDU_BASIC");
        elsif Msg = Fw_Types.Buffer'((7, 3), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SIM_OPEN_CHANNEL");
        elsif Msg = Fw_Types.Buffer'((7, 4), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SIM_CLOSE_CHANNEL");
        elsif Msg = Fw_Types.Buffer'((7, 5), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SIM_TRANSMIT_APDU_CHANNEL");
        elsif Msg = Fw_Types.Buffer'((7, 6), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_NV_READ_ITEM");
        elsif Msg = Fw_Types.Buffer'((7, 7), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_NV_WRITE_ITEM");
        elsif Msg = Fw_Types.Buffer'((7, 8), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_NV_WRITE_CDMA_PRL");
        elsif Msg = Fw_Types.Buffer'((7, 9), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_NV_RESET_CONFIG");
        elsif Msg = Fw_Types.Buffer'((7, 10), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_UICC_SUBSCRIPTION");
        elsif Msg = Fw_Types.Buffer'((7, 11), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_ALLOW_DATA");
        elsif Msg = Fw_Types.Buffer'((7, 12), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GET_HARDWARE_CONFIG");
        elsif Msg = Fw_Types.Buffer'((7, 13), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SIM_AUTHENTICATION");
        elsif Msg = Fw_Types.Buffer'((7, 14), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GET_DC_RT_INFO");
        elsif Msg = Fw_Types.Buffer'((7, 15), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_DC_RT_INFO_RATE");
        elsif Msg = Fw_Types.Buffer'((8, 0), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_DATA_PROFILE");
        elsif Msg = Fw_Types.Buffer'((8, 1), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SHUTDOWN");
        elsif Msg = Fw_Types.Buffer'((8, 2), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GET_RADIO_CAPABILITY");
        elsif Msg = Fw_Types.Buffer'((8, 3), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_RADIO_CAPABILITY");
        elsif Msg = Fw_Types.Buffer'((8, 4), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_START_LCE");
        elsif Msg = Fw_Types.Buffer'((8, 5), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_STOP_LCE");
        elsif Msg = Fw_Types.Buffer'((8, 6), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_PULL_LCEDATA");
        elsif Msg = Fw_Types.Buffer'((8, 7), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GET_ACTIVITY_INFO");
        elsif Msg = Fw_Types.Buffer'((8, 8), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_CARRIER_RESTRICTIONS");
        elsif Msg = Fw_Types.Buffer'((8, 9), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_GET_CARRIER_RESTRICTIONS");
        elsif Msg = Fw_Types.Buffer'((8, 10), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SEND_DEVICE_STATE");
        elsif Msg = Fw_Types.Buffer'((8, 11), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_UNSOLICITED_RESPONSE_FILTER");
        elsif Msg = Fw_Types.Buffer'((8, 12), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_SIM_CARD_POWER");
        elsif Msg = Fw_Types.Buffer'((8, 13), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_SET_CARRIER_INFO_IMSI_ENCRYPTION");
        elsif Msg = Fw_Types.Buffer'((8, 14), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_START_NETWORK_SCAN");
        elsif Msg = Fw_Types.Buffer'((8, 15), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_STOP_NETWORK_SCAN");
        elsif Msg = Fw_Types.Buffer'((9, 0), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_START_KEEPALIVE");
        elsif Msg = Fw_Types.Buffer'((9, 1), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " REQUEST_STOP_KEEPALIVE");
        elsif Msg = Fw_Types.Buffer'((2, 0), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " RESPONSE_ACKNOWLEDGEMENT");
        elsif Msg = Fw_Types.Buffer'((14, 8), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_RESPONSE_BASE");
        elsif Msg = Fw_Types.Buffer'((14, 8), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_RESPONSE_RADIO_STATE_CHANGED");
        elsif Msg = Fw_Types.Buffer'((14, 9), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_RESPONSE_CALL_STATE_CHANGED");
        elsif Msg = Fw_Types.Buffer'((14, 10), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_RESPONSE_VOICE_NETWORK_STATE_CHANGED");
        elsif Msg = Fw_Types.Buffer'((14, 11), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_RESPONSE_NEW_SMS");
        elsif Msg = Fw_Types.Buffer'((14, 12), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_RESPONSE_NEW_SMS_STATUS_REPORT");
        elsif Msg = Fw_Types.Buffer'((14, 13), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_RESPONSE_NEW_SMS_ON_SIM");
        elsif Msg = Fw_Types.Buffer'((14, 14), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_ON_USSD");
        elsif Msg = Fw_Types.Buffer'((14, 15), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_ON_USSD_REQUEST");
        elsif Msg = Fw_Types.Buffer'((15, 0), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_NITZ_TIME_RECEIVED");
        elsif Msg = Fw_Types.Buffer'((15, 1), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_SIGNAL_STRENGTH");
        elsif Msg = Fw_Types.Buffer'((15, 2), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_DATA_CALL_LIST_CHANGED");
        elsif Msg = Fw_Types.Buffer'((15, 3), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_SUPP_SVC_NOTIFICATION");
        elsif Msg = Fw_Types.Buffer'((15, 4), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_STK_SESSION_END");
        elsif Msg = Fw_Types.Buffer'((15, 5), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_STK_PROACTIVE_COMMAND");
        elsif Msg = Fw_Types.Buffer'((15, 6), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_STK_EVENT_NOTIFY");
        elsif Msg = Fw_Types.Buffer'((15, 7), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_STK_CALL_SETUP");
        elsif Msg = Fw_Types.Buffer'((15, 8), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_SIM_SMS_STORAGE_FULL");
        elsif Msg = Fw_Types.Buffer'((15, 9), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_SIM_REFRESH");
        elsif Msg = Fw_Types.Buffer'((15, 10), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_CALL_RING");
        elsif Msg = Fw_Types.Buffer'((15, 11), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_RESPONSE_SIM_STATUS_CHANGED");
        elsif Msg = Fw_Types.Buffer'((15, 12), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_RESPONSE_CDMA_NEW_SMS");
        elsif Msg = Fw_Types.Buffer'((15, 13), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_RESPONSE_NEW_BROADCAST_SMS");
        elsif Msg = Fw_Types.Buffer'((15, 14), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_CDMA_RUIM_SMS_STORAGE_FULL");
        elsif Msg = Fw_Types.Buffer'((15, 15), (0, 3), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_RESTRICTED_STATE_CHANGED");
        elsif Msg = Fw_Types.Buffer'((0, 0), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_ENTER_EMERGENCY_CALLBACK_MODE");
        elsif Msg = Fw_Types.Buffer'((0, 1), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_CDMA_CALL_WAITING");
        elsif Msg = Fw_Types.Buffer'((0, 2), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_CDMA_OTA_PROVISION_STATUS");
        elsif Msg = Fw_Types.Buffer'((0, 3), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_CDMA_INFO_REC");
        elsif Msg = Fw_Types.Buffer'((0, 4), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_OEM_HOOK_RAW");
        elsif Msg = Fw_Types.Buffer'((0, 5), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_RINGBACK_TONE");
        elsif Msg = Fw_Types.Buffer'((0, 6), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_RESEND_INCALL_MUTE");
        elsif Msg = Fw_Types.Buffer'((0, 7), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_CDMA_SUBSCRIPTION_SOURCE_CHANGED");
        elsif Msg = Fw_Types.Buffer'((0, 8), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_CDMA_PRL_CHANGED");
        elsif Msg = Fw_Types.Buffer'((0, 9), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_EXIT_EMERGENCY_CALLBACK_MODE");
        elsif Msg = Fw_Types.Buffer'((0, 10), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_RIL_CONNECTED");
        elsif Msg = Fw_Types.Buffer'((0, 11), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_VOICE_RADIO_TECH_CHANGED");
        elsif Msg = Fw_Types.Buffer'((0, 12), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_CELL_INFO_LIST");
        elsif Msg = Fw_Types.Buffer'((0, 13), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_RESPONSE_IMS_NETWORK_STATE_CHANGED");
        elsif Msg = Fw_Types.Buffer'((0, 14), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_UICC_SUBSCRIPTION_STATUS_CHANGED");
        elsif Msg = Fw_Types.Buffer'((0, 15), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_SRVCC_STATE_NOTIFY");
        elsif Msg = Fw_Types.Buffer'((1, 0), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_HARDWARE_CONFIG_CHANGED");
        elsif Msg = Fw_Types.Buffer'((1, 1), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_DC_RT_INFO_CHANGED");
        elsif Msg = Fw_Types.Buffer'((1, 2), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_RADIO_CAPABILITY");
        elsif Msg = Fw_Types.Buffer'((1, 3), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_ON_SS");
        elsif Msg = Fw_Types.Buffer'((1, 4), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_STK_CC_ALPHA_NOTIFY");
        elsif Msg = Fw_Types.Buffer'((1, 5), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_LCEDATA_RECV");
        elsif Msg = Fw_Types.Buffer'((1, 6), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_PCO_DATA");
        elsif Msg = Fw_Types.Buffer'((1, 7), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_MODEM_RESTART");
        elsif Msg = Fw_Types.Buffer'((1, 8), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_CARRIER_INFO_IMSI_ENCRYPTION");
        elsif Msg = Fw_Types.Buffer'((1, 9), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_NETWORK_SCAN_RESULT");
        elsif Msg = Fw_Types.Buffer'((1, 10), (0, 4), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " UNSOL_KEEPALIVE_STATUS");
        elsif Msg = Fw_Types.Buffer'((0, 0), (0, 0), (0, 0), (0, 0)) then
            Fw_Log.Log (Arrow & " RESPONSE");
        else
            Fw_Log.Hex_Dump (Source.RIL_Packet.ID, RIL_ID);
            Fw_Log.Hex_Dump (Source.RIL_Packet.Token_Event, Token);
            Fw_Log.Log (Arrow & " UNKNOWN: " & RIL_ID & " TOKEN: " & Token);
        end if;

        return Fw_Types.Accepted;
    end Analyze;

end Baseband_Fw;
