with Genode_Log;
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

    procedure Filter_Hook
      (Dest      : System.Address;
       Src       : System.Address;
       Dest_Size : Integer;
       Src_Size  : Integer;
       Dir       : Integer)
    with
        SPARK_Mode => Off
    is
        Dest_Buf : Fw_Types.Buffer (0 .. Dest_Size);
        for Dest_Buf'Address use Dest;

        Src_Buf : Fw_Types.Buffer (0 .. Src_Size);
        for Src_Buf'Address use Src;

        Src_Packet : Fw_Types.Packet;
        for Src_Packet'Address use Src;

    begin
        Filter (Src_Buf, Src_Packet, Dest_Buf, Fw_Types.Direction'Val (Dir));
    end Filter_Hook;

    procedure Copy
      (Dest :    out Fw_Types.Buffer;
       Src  :        Fw_Types.Buffer)
    is
    begin
        Dest := Src;
    end Copy;

    procedure Analyze
      (Source :        Fw_Types.Packet;
       Dir    :        Fw_Types.Direction;
       Result :    out Fw_Types.Status)
    is
        Arrow  : constant Fw_Log.Arrow := Fw_Log.Directed_Arrow (Dir);
        RIL_ID : String (1 .. 8);
        Token  : String (1 .. 8);
        Msg    : Fw_Types.Buffer (0 .. 3);
    begin

        if Source.IP_Header.Protocol = RIL_Proxy_Proto and
           Source.UDP_Header.Source = RIL_Proxy_Port and
           Source.UDP_Header.Destination = RIL_Proxy_Port
        then
            Msg := Source.RIL_Packet.ID;
            Result := Accepted;

            if Msg = RIL_Proxy_Setup then
                Genode_Log.Log (Arrow & " SETUP");
            elsif Msg = RIL_Proxy_Teardown then
                Genode_Log.Log (Arrow & " TEARDOWN");
            elsif Msg = Fw_Types.Buffer'(16#01#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GET_SIM_STATUS");
            elsif Msg = Fw_Types.Buffer'(16#02#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_ENTER_SIM_PIN");
            elsif Msg = Fw_Types.Buffer'(16#03#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_ENTER_SIM_PUK");
            elsif Msg = Fw_Types.Buffer'(16#04#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_ENTER_SIM_PIN2");
            elsif Msg = Fw_Types.Buffer'(16#05#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_ENTER_SIM_PUK2");
            elsif Msg = Fw_Types.Buffer'(16#06#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CHANGE_SIM_PIN");
            elsif Msg = Fw_Types.Buffer'(16#07#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CHANGE_SIM_PIN2");
            elsif Msg = Fw_Types.Buffer'(16#08#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_ENTER_NETWORK_DEPERSONALIZATION");
            elsif Msg = Fw_Types.Buffer'(16#09#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GET_CURRENT_CALLS");
            elsif Msg = Fw_Types.Buffer'(16#0a#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_DIAL");
            elsif Msg = Fw_Types.Buffer'(16#0b#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GET_IMSI");
            elsif Msg = Fw_Types.Buffer'(16#0c#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_HANGUP");
            elsif Msg = Fw_Types.Buffer'(16#0d#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_HANGUP_WAITING_OR_BACKGROUND");
            elsif Msg = Fw_Types.Buffer'(16#0e#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_HANGUP_FOREGROUND_RESUME_BACKGROUND");
            elsif Msg = Fw_Types.Buffer'(16#0f#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SWITCH_WAITING_OR_HOLDING_AND_ACTIVE");
            elsif Msg = Fw_Types.Buffer'(16#0f#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SWITCH_HOLDING_AND_ACTIVE");
            elsif Msg = Fw_Types.Buffer'(16#10#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CONFERENCE");
            elsif Msg = Fw_Types.Buffer'(16#11#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_UDUB");
            elsif Msg = Fw_Types.Buffer'(16#12#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_LAST_CALL_FAIL_CAUSE");
            elsif Msg = Fw_Types.Buffer'(16#13#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SIGNAL_STRENGTH");
            elsif Msg = Fw_Types.Buffer'(16#14#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_VOICE_REGISTRATION_STATE");
            elsif Msg = Fw_Types.Buffer'(16#15#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_DATA_REGISTRATION_STATE");
            elsif Msg = Fw_Types.Buffer'(16#16#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_OPERATOR");
            elsif Msg = Fw_Types.Buffer'(16#17#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_RADIO_POWER");
            elsif Msg = Fw_Types.Buffer'(16#18#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_DTMF");
            elsif Msg = Fw_Types.Buffer'(16#19#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SEND_SMS");
            elsif Msg = Fw_Types.Buffer'(16#1a#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SEND_SMS_EXPECT_MORE");
            elsif Msg = Fw_Types.Buffer'(16#1b#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SETUP_DATA_CALL");
            elsif Msg = Fw_Types.Buffer'(16#1c#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SIM_IO");
            elsif Msg = Fw_Types.Buffer'(16#1d#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SEND_USSD");
            elsif Msg = Fw_Types.Buffer'(16#1e#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CANCEL_USSD");
            elsif Msg = Fw_Types.Buffer'(16#1f#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GET_CLIR");
            elsif Msg = Fw_Types.Buffer'(16#20#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_CLIR");
            elsif Msg = Fw_Types.Buffer'(16#21#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_QUERY_CALL_FORWARD_STATUS");
            elsif Msg = Fw_Types.Buffer'(16#22#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_CALL_FORWARD");
            elsif Msg = Fw_Types.Buffer'(16#23#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_QUERY_CALL_WAITING");
            elsif Msg = Fw_Types.Buffer'(16#24#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_CALL_WAITING");
            elsif Msg = Fw_Types.Buffer'(16#25#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SMS_ACKNOWLEDGE");
            elsif Msg = Fw_Types.Buffer'(16#26#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GET_IMEI");
            elsif Msg = Fw_Types.Buffer'(16#27#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GET_IMEISV");
            elsif Msg = Fw_Types.Buffer'(16#28#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_ANSWER");
            elsif Msg = Fw_Types.Buffer'(16#29#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_DEACTIVATE_DATA_CALL");
            elsif Msg = Fw_Types.Buffer'(16#2a#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_QUERY_FACILITY_LOCK");
            elsif Msg = Fw_Types.Buffer'(16#2b#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_FACILITY_LOCK");
            elsif Msg = Fw_Types.Buffer'(16#2c#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CHANGE_BARRING_PASSWORD");
            elsif Msg = Fw_Types.Buffer'(16#2d#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_QUERY_NETWORK_SELECTION_MODE");
            elsif Msg = Fw_Types.Buffer'(16#2e#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_NETWORK_SELECTION_AUTOMATIC");
            elsif Msg = Fw_Types.Buffer'(16#2f#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_NETWORK_SELECTION_MANUAL");
            elsif Msg = Fw_Types.Buffer'(16#30#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_QUERY_AVAILABLE_NETWORKS");
            elsif Msg = Fw_Types.Buffer'(16#31#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_DTMF_START");
            elsif Msg = Fw_Types.Buffer'(16#32#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_DTMF_STOP");
            elsif Msg = Fw_Types.Buffer'(16#33#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_BASEBAND_VERSION");
            elsif Msg = Fw_Types.Buffer'(16#34#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SEPARATE_CONNECTION");
            elsif Msg = Fw_Types.Buffer'(16#35#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_MUTE");
            elsif Msg = Fw_Types.Buffer'(16#36#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GET_MUTE");
            elsif Msg = Fw_Types.Buffer'(16#37#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_QUERY_CLIP");
            elsif Msg = Fw_Types.Buffer'(16#38#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_LAST_DATA_CALL_FAIL_CAUSE");
            elsif Msg = Fw_Types.Buffer'(16#39#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_DATA_CALL_LIST");
            elsif Msg = Fw_Types.Buffer'(16#3a#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_RESET_RADIO");
            elsif Msg = Fw_Types.Buffer'(16#3b#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_OEM_HOOK_RAW");
            elsif Msg = Fw_Types.Buffer'(16#3c#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_OEM_HOOK_STRINGS");
            elsif Msg = Fw_Types.Buffer'(16#3d#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SCREEN_STATE");
            elsif Msg = Fw_Types.Buffer'(16#3e#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_SUPP_SVC_NOTIFICATION");
            elsif Msg = Fw_Types.Buffer'(16#3f#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_WRITE_SMS_TO_SIM");
            elsif Msg = Fw_Types.Buffer'(16#40#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_DELETE_SMS_ON_SIM");
            elsif Msg = Fw_Types.Buffer'(16#41#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_BAND_MODE");
            elsif Msg = Fw_Types.Buffer'(16#42#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_QUERY_AVAILABLE_BAND_MODE");
            elsif Msg = Fw_Types.Buffer'(16#43#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_STK_GET_PROFILE");
            elsif Msg = Fw_Types.Buffer'(16#44#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_STK_SET_PROFILE");
            elsif Msg = Fw_Types.Buffer'(16#45#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_STK_SEND_ENVELOPE_COMMAND");
            elsif Msg = Fw_Types.Buffer'(16#46#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_STK_SEND_TERMINAL_RESPONSE");
            elsif Msg = Fw_Types.Buffer'(16#47#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_STK_HANDLE_CALL_SETUP_REQUESTED_FROM_SIM");
            elsif Msg = Fw_Types.Buffer'(16#48#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_EXPLICIT_CALL_TRANSFER");
            elsif Msg = Fw_Types.Buffer'(16#49#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_PREFERRED_NETWORK_TYPE");
            elsif Msg = Fw_Types.Buffer'(16#4a#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GET_PREFERRED_NETWORK_TYPE");
            elsif Msg = Fw_Types.Buffer'(16#4b#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GET_NEIGHBORING_CELL_IDS");
            elsif Msg = Fw_Types.Buffer'(16#4c#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_LOCATION_UPDATES");
            elsif Msg = Fw_Types.Buffer'(16#4d#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_SET_SUBSCRIPTION_SOURCE");
            elsif Msg = Fw_Types.Buffer'(16#4e#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_SET_ROAMING_PREFERENCE");
            elsif Msg = Fw_Types.Buffer'(16#4f#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_QUERY_ROAMING_PREFERENCE");
            elsif Msg = Fw_Types.Buffer'(16#50#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_TTY_MODE");
            elsif Msg = Fw_Types.Buffer'(16#51#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_QUERY_TTY_MODE");
            elsif Msg = Fw_Types.Buffer'(16#52#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_SET_PREFERRED_VOICE_PRIVACY_MODE");
            elsif Msg = Fw_Types.Buffer'(16#53#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_QUERY_PREFERRED_VOICE_PRIVACY_MODE");
            elsif Msg = Fw_Types.Buffer'(16#54#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_FLASH");
            elsif Msg = Fw_Types.Buffer'(16#55#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_BURST_DTMF");
            elsif Msg = Fw_Types.Buffer'(16#56#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_VALIDATE_AND_WRITE_AKEY");
            elsif Msg = Fw_Types.Buffer'(16#57#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_SEND_SMS");
            elsif Msg = Fw_Types.Buffer'(16#58#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_SMS_ACKNOWLEDGE");
            elsif Msg = Fw_Types.Buffer'(16#59#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GSM_GET_BROADCAST_SMS_CONFIG");
            elsif Msg = Fw_Types.Buffer'(16#5a#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GSM_SET_BROADCAST_SMS_CONFIG");
            elsif Msg = Fw_Types.Buffer'(16#5b#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GSM_SMS_BROADCAST_ACTIVATION");
            elsif Msg = Fw_Types.Buffer'(16#5c#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_GET_BROADCAST_SMS_CONFIG");
            elsif Msg = Fw_Types.Buffer'(16#5d#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_SET_BROADCAST_SMS_CONFIG");
            elsif Msg = Fw_Types.Buffer'(16#5e#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_SMS_BROADCAST_ACTIVATION");
            elsif Msg = Fw_Types.Buffer'(16#5f#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_SUBSCRIPTION");
            elsif Msg = Fw_Types.Buffer'(16#60#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_WRITE_SMS_TO_RUIM");
            elsif Msg = Fw_Types.Buffer'(16#61#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_DELETE_SMS_ON_RUIM");
            elsif Msg = Fw_Types.Buffer'(16#62#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_DEVICE_IDENTITY");
            elsif Msg = Fw_Types.Buffer'(16#63#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_EXIT_EMERGENCY_CALLBACK_MODE");
            elsif Msg = Fw_Types.Buffer'(16#64#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GET_SMSC_ADDRESS");
            elsif Msg = Fw_Types.Buffer'(16#65#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_SMSC_ADDRESS");
            elsif Msg = Fw_Types.Buffer'(16#66#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_REPORT_SMS_MEMORY_STATUS");
            elsif Msg = Fw_Types.Buffer'(16#67#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_REPORT_STK_SERVICE_IS_RUNNING");
            elsif Msg = Fw_Types.Buffer'(16#68#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_GET_SUBSCRIPTION_SOURCE");
            elsif Msg = Fw_Types.Buffer'(16#69#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_ISIM_AUTHENTICATION");
            elsif Msg = Fw_Types.Buffer'(16#6a#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_ACKNOWLEDGE_INCOMING_GSM_SMS_WITH_PDU");
            elsif Msg = Fw_Types.Buffer'(16#6b#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_STK_SEND_ENVELOPE_WITH_STATUS");
            elsif Msg = Fw_Types.Buffer'(16#6c#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_VOICE_RADIO_TECH");
            elsif Msg = Fw_Types.Buffer'(16#6d#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GET_CELL_INFO_LIST");
            elsif Msg = Fw_Types.Buffer'(16#6e#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_UNSOL_CELL_INFO_LIST_RATE");
            elsif Msg = Fw_Types.Buffer'(16#6f#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_INITIAL_ATTACH_APN");
            elsif Msg = Fw_Types.Buffer'(16#70#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_IMS_REGISTRATION_STATE");
            elsif Msg = Fw_Types.Buffer'(16#71#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_IMS_SEND_SMS");
            elsif Msg = Fw_Types.Buffer'(16#72#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SIM_TRANSMIT_APDU_BASIC");
            elsif Msg = Fw_Types.Buffer'(16#73#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SIM_OPEN_CHANNEL");
            elsif Msg = Fw_Types.Buffer'(16#74#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SIM_CLOSE_CHANNEL");
            elsif Msg = Fw_Types.Buffer'(16#75#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SIM_TRANSMIT_APDU_CHANNEL");
            elsif Msg = Fw_Types.Buffer'(16#76#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_NV_READ_ITEM");
            elsif Msg = Fw_Types.Buffer'(16#77#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_NV_WRITE_ITEM");
            elsif Msg = Fw_Types.Buffer'(16#78#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_NV_WRITE_CDMA_PRL");
            elsif Msg = Fw_Types.Buffer'(16#79#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_NV_RESET_CONFIG");
            elsif Msg = Fw_Types.Buffer'(16#7a#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_UICC_SUBSCRIPTION");
            elsif Msg = Fw_Types.Buffer'(16#7b#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_ALLOW_DATA");
            elsif Msg = Fw_Types.Buffer'(16#7c#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GET_HARDWARE_CONFIG");
            elsif Msg = Fw_Types.Buffer'(16#7d#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SIM_AUTHENTICATION");
            elsif Msg = Fw_Types.Buffer'(16#7e#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GET_DC_RT_INFO");
            elsif Msg = Fw_Types.Buffer'(16#7f#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_DC_RT_INFO_RATE");
            elsif Msg = Fw_Types.Buffer'(16#80#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_DATA_PROFILE");
            elsif Msg = Fw_Types.Buffer'(16#81#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SHUTDOWN");
            elsif Msg = Fw_Types.Buffer'(16#82#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GET_RADIO_CAPABILITY");
            elsif Msg = Fw_Types.Buffer'(16#83#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_RADIO_CAPABILITY");
            elsif Msg = Fw_Types.Buffer'(16#84#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_START_LCE");
            elsif Msg = Fw_Types.Buffer'(16#85#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_STOP_LCE");
            elsif Msg = Fw_Types.Buffer'(16#86#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_PULL_LCEDATA");
            elsif Msg = Fw_Types.Buffer'(16#87#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GET_ACTIVITY_INFO");
            elsif Msg = Fw_Types.Buffer'(16#88#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_SET_CARRIER_RESTRICTIONS");
            elsif Msg = Fw_Types.Buffer'(16#89#, 16#00#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " REQUEST_GET_CARRIER_RESTRICTIONS");
            elsif Msg = Fw_Types.Buffer'(16#20#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " RESPONSE_ACKNOWLEDGEMENT");
            elsif Msg = Fw_Types.Buffer'(16#e8#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_BASE");
            elsif Msg = Fw_Types.Buffer'(16#e8#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_RADIO_STATE_CHANGED");
            elsif Msg = Fw_Types.Buffer'(16#e9#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_CALL_STATE_CHANGED");
            elsif Msg = Fw_Types.Buffer'(16#ea#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_VOICE_NETWORK_STATE_CHANGED");
            elsif Msg = Fw_Types.Buffer'(16#eb#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_NEW_SMS");
            elsif Msg = Fw_Types.Buffer'(16#ec#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_NEW_SMS_STATUS_REPORT");
            elsif Msg = Fw_Types.Buffer'(16#ed#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_NEW_SMS_ON_SIM");
            elsif Msg = Fw_Types.Buffer'(16#ee#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_ON_USSD");
            elsif Msg = Fw_Types.Buffer'(16#ef#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_ON_USSD_REQUEST");
            elsif Msg = Fw_Types.Buffer'(16#f0#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_NITZ_TIME_RECEIVED");
            elsif Msg = Fw_Types.Buffer'(16#f1#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_SIGNAL_STRENGTH");
            elsif Msg = Fw_Types.Buffer'(16#f2#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_DATA_CALL_LIST_CHANGED");
            elsif Msg = Fw_Types.Buffer'(16#f3#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_SUPP_SVC_NOTIFICATION");
            elsif Msg = Fw_Types.Buffer'(16#f4#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_STK_SESSION_END");
            elsif Msg = Fw_Types.Buffer'(16#f5#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_STK_PROACTIVE_COMMAND");
            elsif Msg = Fw_Types.Buffer'(16#f6#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_STK_EVENT_NOTIFY");
            elsif Msg = Fw_Types.Buffer'(16#f7#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_STK_CALL_SETUP");
            elsif Msg = Fw_Types.Buffer'(16#f8#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_SIM_SMS_STORAGE_FULL");
            elsif Msg = Fw_Types.Buffer'(16#f9#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_SIM_REFRESH");
            elsif Msg = Fw_Types.Buffer'(16#fa#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_CALL_RING");
            elsif Msg = Fw_Types.Buffer'(16#fb#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_SIM_STATUS_CHANGED");
            elsif Msg = Fw_Types.Buffer'(16#fc#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_CDMA_NEW_SMS");
            elsif Msg = Fw_Types.Buffer'(16#fd#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_NEW_BROADCAST_SMS");
            elsif Msg = Fw_Types.Buffer'(16#fe#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_CDMA_RUIM_SMS_STORAGE_FULL");
            elsif Msg = Fw_Types.Buffer'(16#ff#, 16#03#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_RESTRICTED_STATE_CHANGED");
            elsif Msg = Fw_Types.Buffer'(16#00#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_ENTER_EMERGENCY_CALLBACK_MODE");
            elsif Msg = Fw_Types.Buffer'(16#01#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_CDMA_CALL_WAITING");
            elsif Msg = Fw_Types.Buffer'(16#02#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_CDMA_OTA_PROVISION_STATUS");
            elsif Msg = Fw_Types.Buffer'(16#03#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_CDMA_INFO_REC");
            elsif Msg = Fw_Types.Buffer'(16#04#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_OEM_HOOK_RAW");
            elsif Msg = Fw_Types.Buffer'(16#05#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_RINGBACK_TONE");
            elsif Msg = Fw_Types.Buffer'(16#06#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_RESEND_INCALL_MUTE");
            elsif Msg = Fw_Types.Buffer'(16#07#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_CDMA_SUBSCRIPTION_SOURCE_CHANGED");
            elsif Msg = Fw_Types.Buffer'(16#08#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_CDMA_PRL_CHANGED");
            elsif Msg = Fw_Types.Buffer'(16#09#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_EXIT_EMERGENCY_CALLBACK_MODE");
            elsif Msg = Fw_Types.Buffer'(16#0a#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_RIL_CONNECTED");
            elsif Msg = Fw_Types.Buffer'(16#0b#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_VOICE_RADIO_TECH_CHANGED");
            elsif Msg = Fw_Types.Buffer'(16#0c#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_CELL_INFO_LIST");
            elsif Msg = Fw_Types.Buffer'(16#0d#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_IMS_NETWORK_STATE_CHANGED");
            elsif Msg = Fw_Types.Buffer'(16#0e#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_UICC_SUBSCRIPTION_STATUS_CHANGED");
            elsif Msg = Fw_Types.Buffer'(16#0f#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_SRVCC_STATE_NOTIFY");
            elsif Msg = Fw_Types.Buffer'(16#10#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_HARDWARE_CONFIG_CHANGED");
            elsif Msg = Fw_Types.Buffer'(16#11#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_DC_RT_INFO_CHANGED");
            elsif Msg = Fw_Types.Buffer'(16#12#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_RADIO_CAPABILITY");
            elsif Msg = Fw_Types.Buffer'(16#13#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_ON_SS");
            elsif Msg = Fw_Types.Buffer'(16#14#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_STK_CC_ALPHA_NOTIFY");
            elsif Msg = Fw_Types.Buffer'(16#15#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_LCEDATA_RECV");
            elsif Msg = Fw_Types.Buffer'(16#16#, 16#04#, 16#00#, 16#00#) then
                Genode_Log.Log (Arrow & " UNSOL_PCO_DATA");
            elsif Msg = Fw_Types.Buffer'(0, 0, 0, 0) then
                Genode_Log.Log (Arrow & " RESPONSE");
            else
                Fw_Log.Hex_Dump (Source.RIL_Packet.ID, RIL_ID);
                Fw_Log.Hex_Dump (Source.RIL_Packet.Token_Event, Token);
                Genode_Log.Log (Arrow & " UNKNOWN: " & RIL_ID & " TOKEN: " & Token);
                Result := Fw_Types.Rejected;
            end if;
        else
            Result := Fw_Types.Rejected;
        end if;
    end Analyze;

    --  FIXME: We should do the conversion from Packet -> Buffer in SPARK!
    procedure Filter
        (Source_Buffer      :        Fw_Types.Buffer;
         Source_Packet      :        Fw_Types.Packet;
         Destination_Buffer : in out Fw_Types.Buffer;
         Direction          :        Fw_Types.Direction)
    is
        Packet_Status : Fw_Types.Status;
    begin
        Analyze (Source_Packet, Direction, Packet_Status);
        case Packet_Status
        is
            when Fw_Types.Accepted =>
                Copy (Src => Source_Buffer, Dest => Destination_Buffer);
            when Fw_Types.Rejected =>
                Copy (Src => Source_Buffer, Dest => Destination_Buffer);
        end case;
    end Filter;

end Baseband_Fw;
