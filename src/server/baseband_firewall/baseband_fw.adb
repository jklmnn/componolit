with Genode_Log;
with Fw_Log;
with Fw_Types;
use all type Fw_Types.U16;
use all type Fw_Types.U32;
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
        Msg    : Fw_Types.U32;
    begin

        if Source.Eth_Header.Ethtype = RIL_Proxy_Ethtype
        then
            Msg := Source.RIL_Header.ID;
            Result := Accepted;

            if Msg = RIL_Proxy_Setup then
                Genode_Log.Log (Arrow & " SETUP");
            elsif Msg = RIL_Proxy_Teardown then
                Genode_Log.Log (Arrow & " TEARDOWN");
            elsif Msg = 16#01000000# then
                Genode_Log.Log (Arrow & " REQUEST_GET_SIM_STATUS");
            elsif Msg = 16#02000000# then
                Genode_Log.Log (Arrow & " REQUEST_ENTER_SIM_PIN");
            elsif Msg = 16#03000000# then
                Genode_Log.Log (Arrow & " REQUEST_ENTER_SIM_PUK");
            elsif Msg = 16#04000000# then
                Genode_Log.Log (Arrow & " REQUEST_ENTER_SIM_PIN2");
            elsif Msg = 16#05000000# then
                Genode_Log.Log (Arrow & " REQUEST_ENTER_SIM_PUK2");
            elsif Msg = 16#06000000# then
                Genode_Log.Log (Arrow & " REQUEST_CHANGE_SIM_PIN");
            elsif Msg = 16#07000000# then
                Genode_Log.Log (Arrow & " REQUEST_CHANGE_SIM_PIN2");
            elsif Msg = 16#08000000# then
                Genode_Log.Log (Arrow & " REQUEST_ENTER_NETWORK_DEPERSONALIZATION");
            elsif Msg = 16#09000000# then
                Genode_Log.Log (Arrow & " REQUEST_GET_CURRENT_CALLS");
            elsif Msg = 16#0a000000# then
                Genode_Log.Log (Arrow & " REQUEST_DIAL");
            elsif Msg = 16#0b000000# then
                Genode_Log.Log (Arrow & " REQUEST_GET_IMSI");
            elsif Msg = 16#0c000000# then
                Genode_Log.Log (Arrow & " REQUEST_HANGUP");
            elsif Msg = 16#0d000000# then
                Genode_Log.Log (Arrow & " REQUEST_HANGUP_WAITING_OR_BACKGROUND");
            elsif Msg = 16#0e000000# then
                Genode_Log.Log (Arrow & " REQUEST_HANGUP_FOREGROUND_RESUME_BACKGROUND");
            elsif Msg = 16#0f000000# then
                Genode_Log.Log (Arrow & " REQUEST_SWITCH_WAITING_OR_HOLDING_AND_ACTIVE");
            elsif Msg = 16#10000000# then
                Genode_Log.Log (Arrow & " REQUEST_CONFERENCE");
            elsif Msg = 16#11000000# then
                Genode_Log.Log (Arrow & " REQUEST_UDUB");
            elsif Msg = 16#12000000# then
                Genode_Log.Log (Arrow & " REQUEST_LAST_CALL_FAIL_CAUSE");
            elsif Msg = 16#13000000# then
                Genode_Log.Log (Arrow & " REQUEST_SIGNAL_STRENGTH");
            elsif Msg = 16#14000000# then
                Genode_Log.Log (Arrow & " REQUEST_VOICE_REGISTRATION_STATE");
            elsif Msg = 16#15000000# then
                Genode_Log.Log (Arrow & " REQUEST_DATA_REGISTRATION_STATE");
            elsif Msg = 16#16000000# then
                Genode_Log.Log (Arrow & " REQUEST_OPERATOR");
            elsif Msg = 16#17000000# then
                Genode_Log.Log (Arrow & " REQUEST_RADIO_POWER");
            elsif Msg = 16#18000000# then
                Genode_Log.Log (Arrow & " REQUEST_DTMF");
            elsif Msg = 16#19000000# then
                Genode_Log.Log (Arrow & " REQUEST_SEND_SMS");
            elsif Msg = 16#1a000000# then
                Genode_Log.Log (Arrow & " REQUEST_SEND_SMS_EXPECT_MORE");
            elsif Msg = 16#1b000000# then
                Genode_Log.Log (Arrow & " REQUEST_SETUP_DATA_CALL");
            elsif Msg = 16#1c000000# then
                Genode_Log.Log (Arrow & " REQUEST_SIM_IO");
            elsif Msg = 16#1d000000# then
                Genode_Log.Log (Arrow & " REQUEST_SEND_USSD");
            elsif Msg = 16#1e000000# then
                Genode_Log.Log (Arrow & " REQUEST_CANCEL_USSD");
            elsif Msg = 16#1f000000# then
                Genode_Log.Log (Arrow & " REQUEST_GET_CLIR");
            elsif Msg = 16#20000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_CLIR");
            elsif Msg = 16#21000000# then
                Genode_Log.Log (Arrow & " REQUEST_QUERY_CALL_FORWARD_STATUS");
            elsif Msg = 16#22000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_CALL_FORWARD");
            elsif Msg = 16#23000000# then
                Genode_Log.Log (Arrow & " REQUEST_QUERY_CALL_WAITING");
            elsif Msg = 16#24000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_CALL_WAITING");
            elsif Msg = 16#25000000# then
                Genode_Log.Log (Arrow & " REQUEST_SMS_ACKNOWLEDGE");
            elsif Msg = 16#26000000# then
                Genode_Log.Log (Arrow & " REQUEST_GET_IMEI");
            elsif Msg = 16#27000000# then
                Genode_Log.Log (Arrow & " REQUEST_GET_IMEISV");
            elsif Msg = 16#28000000# then
                Genode_Log.Log (Arrow & " REQUEST_ANSWER");
            elsif Msg = 16#29000000# then
                Genode_Log.Log (Arrow & " REQUEST_DEACTIVATE_DATA_CALL");
            elsif Msg = 16#2a000000# then
                Genode_Log.Log (Arrow & " REQUEST_QUERY_FACILITY_LOCK");
            elsif Msg = 16#2b000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_FACILITY_LOCK");
            elsif Msg = 16#2c000000# then
                Genode_Log.Log (Arrow & " REQUEST_CHANGE_BARRING_PASSWORD");
            elsif Msg = 16#2d000000# then
                Genode_Log.Log (Arrow & " REQUEST_QUERY_NETWORK_SELECTION_MODE");
            elsif Msg = 16#2e000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_NETWORK_SELECTION_AUTOMATIC");
            elsif Msg = 16#2f000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_NETWORK_SELECTION_MANUAL");
            elsif Msg = 16#30000000# then
                Genode_Log.Log (Arrow & " REQUEST_QUERY_AVAILABLE_NETWORKS");
            elsif Msg = 16#31000000# then
                Genode_Log.Log (Arrow & " REQUEST_DTMF_START");
            elsif Msg = 16#32000000# then
                Genode_Log.Log (Arrow & " REQUEST_DTMF_STOP");
            elsif Msg = 16#33000000# then
                Genode_Log.Log (Arrow & " REQUEST_BASEBAND_VERSION");
            elsif Msg = 16#34000000# then
                Genode_Log.Log (Arrow & " REQUEST_SEPARATE_CONNECTION");
            elsif Msg = 16#35000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_MUTE");
            elsif Msg = 16#36000000# then
                Genode_Log.Log (Arrow & " REQUEST_GET_MUTE");
            elsif Msg = 16#37000000# then
                Genode_Log.Log (Arrow & " REQUEST_QUERY_CLIP");
            elsif Msg = 16#38000000# then
                Genode_Log.Log (Arrow & " REQUEST_LAST_DATA_CALL_FAIL_CAUSE");
            elsif Msg = 16#39000000# then
                Genode_Log.Log (Arrow & " REQUEST_DATA_CALL_LIST");
            elsif Msg = 16#3a000000# then
                Genode_Log.Log (Arrow & " REQUEST_RESET_RADIO");
            elsif Msg = 16#3b000000# then
                Genode_Log.Log (Arrow & " REQUEST_OEM_HOOK_RAW");
            elsif Msg = 16#3c000000# then
                Genode_Log.Log (Arrow & " REQUEST_OEM_HOOK_STRINGS");
            elsif Msg = 16#3d000000# then
                Genode_Log.Log (Arrow & " REQUEST_SCREEN_STATE");
            elsif Msg = 16#3e000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_SUPP_SVC_NOTIFICATION");
            elsif Msg = 16#3f000000# then
                Genode_Log.Log (Arrow & " REQUEST_WRITE_SMS_TO_SIM");
            elsif Msg = 16#40000000# then
                Genode_Log.Log (Arrow & " REQUEST_DELETE_SMS_ON_SIM");
            elsif Msg = 16#41000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_BAND_MODE");
            elsif Msg = 16#42000000# then
                Genode_Log.Log (Arrow & " REQUEST_QUERY_AVAILABLE_BAND_MODE");
            elsif Msg = 16#43000000# then
                Genode_Log.Log (Arrow & " REQUEST_STK_GET_PROFILE");
            elsif Msg = 16#44000000# then
                Genode_Log.Log (Arrow & " REQUEST_STK_SET_PROFILE");
            elsif Msg = 16#45000000# then
                Genode_Log.Log (Arrow & " REQUEST_STK_SEND_ENVELOPE_COMMAND");
            elsif Msg = 16#46000000# then
                Genode_Log.Log (Arrow & " REQUEST_STK_SEND_TERMINAL_RESPONSE");
            elsif Msg = 16#47000000# then
                Genode_Log.Log (Arrow & " REQUEST_STK_HANDLE_CALL_SETUP_REQUESTED_FROM_SIM");
            elsif Msg = 16#48000000# then
                Genode_Log.Log (Arrow & " REQUEST_EXPLICIT_CALL_TRANSFER");
            elsif Msg = 16#49000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_PREFERRED_NETWORK_TYPE");
            elsif Msg = 16#4a000000# then
                Genode_Log.Log (Arrow & " REQUEST_GET_PREFERRED_NETWORK_TYPE");
            elsif Msg = 16#4b000000# then
                Genode_Log.Log (Arrow & " REQUEST_GET_NEIGHBORING_CELL_IDS");
            elsif Msg = 16#4c000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_LOCATION_UPDATES");
            elsif Msg = 16#4d000000# then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_SET_SUBSCRIPTION_SOURCE");
            elsif Msg = 16#4e000000# then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_SET_ROAMING_PREFERENCE");
            elsif Msg = 16#4f000000# then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_QUERY_ROAMING_PREFERENCE");
            elsif Msg = 16#50000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_TTY_MODE");
            elsif Msg = 16#51000000# then
                Genode_Log.Log (Arrow & " REQUEST_QUERY_TTY_MODE");
            elsif Msg = 16#52000000# then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_SET_PREFERRED_VOICE_PRIVACY_MODE");
            elsif Msg = 16#53000000# then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_QUERY_PREFERRED_VOICE_PRIVACY_MODE");
            elsif Msg = 16#54000000# then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_FLASH");
            elsif Msg = 16#55000000# then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_BURST_DTMF");
            elsif Msg = 16#56000000# then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_VALIDATE_AND_WRITE_AKEY");
            elsif Msg = 16#57000000# then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_SEND_SMS");
            elsif Msg = 16#58000000# then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_SMS_ACKNOWLEDGE");
            elsif Msg = 16#59000000# then
                Genode_Log.Log (Arrow & " REQUEST_GSM_GET_BROADCAST_SMS_CONFIG");
            elsif Msg = 16#5a000000# then
                Genode_Log.Log (Arrow & " REQUEST_GSM_SET_BROADCAST_SMS_CONFIG");
            elsif Msg = 16#5b000000# then
                Genode_Log.Log (Arrow & " REQUEST_GSM_SMS_BROADCAST_ACTIVATION");
            elsif Msg = 16#5c000000# then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_GET_BROADCAST_SMS_CONFIG");
            elsif Msg = 16#5d000000# then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_SET_BROADCAST_SMS_CONFIG");
            elsif Msg = 16#5e000000# then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_SMS_BROADCAST_ACTIVATION");
            elsif Msg = 16#5f000000# then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_SUBSCRIPTION");
            elsif Msg = 16#60000000# then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_WRITE_SMS_TO_RUIM");
            elsif Msg = 16#61000000# then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_DELETE_SMS_ON_RUIM");
            elsif Msg = 16#62000000# then
                Genode_Log.Log (Arrow & " REQUEST_DEVICE_IDENTITY");
            elsif Msg = 16#63000000# then
                Genode_Log.Log (Arrow & " REQUEST_EXIT_EMERGENCY_CALLBACK_MODE");
            elsif Msg = 16#64000000# then
                Genode_Log.Log (Arrow & " REQUEST_GET_SMSC_ADDRESS");
            elsif Msg = 16#65000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_SMSC_ADDRESS");
            elsif Msg = 16#66000000# then
                Genode_Log.Log (Arrow & " REQUEST_REPORT_SMS_MEMORY_STATUS");
            elsif Msg = 16#67000000# then
                Genode_Log.Log (Arrow & " REQUEST_REPORT_STK_SERVICE_IS_RUNNING");
            elsif Msg = 16#68000000# then
                Genode_Log.Log (Arrow & " REQUEST_CDMA_GET_SUBSCRIPTION_SOURCE");
            elsif Msg = 16#69000000# then
                Genode_Log.Log (Arrow & " REQUEST_ISIM_AUTHENTICATION");
            elsif Msg = 16#6a000000# then
                Genode_Log.Log (Arrow & " REQUEST_ACKNOWLEDGE_INCOMING_GSM_SMS_WITH_PDU");
            elsif Msg = 16#6b000000# then
                Genode_Log.Log (Arrow & " REQUEST_STK_SEND_ENVELOPE_WITH_STATUS");
            elsif Msg = 16#6c000000# then
                Genode_Log.Log (Arrow & " REQUEST_VOICE_RADIO_TECH");
            elsif Msg = 16#6d000000# then
                Genode_Log.Log (Arrow & " REQUEST_GET_CELL_INFO_LIST");
            elsif Msg = 16#6e000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_UNSOL_CELL_INFO_LIST_RATE");
            elsif Msg = 16#6f000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_INITIAL_ATTACH_APN");
            elsif Msg = 16#70000000# then
                Genode_Log.Log (Arrow & " REQUEST_IMS_REGISTRATION_STATE");
            elsif Msg = 16#71000000# then
                Genode_Log.Log (Arrow & " REQUEST_IMS_SEND_SMS");
            elsif Msg = 16#72000000# then
                Genode_Log.Log (Arrow & " REQUEST_SIM_TRANSMIT_APDU_BASIC");
            elsif Msg = 16#73000000# then
                Genode_Log.Log (Arrow & " REQUEST_SIM_OPEN_CHANNEL");
            elsif Msg = 16#74000000# then
                Genode_Log.Log (Arrow & " REQUEST_SIM_CLOSE_CHANNEL");
            elsif Msg = 16#75000000# then
                Genode_Log.Log (Arrow & " REQUEST_SIM_TRANSMIT_APDU_CHANNEL");
            elsif Msg = 16#76000000# then
                Genode_Log.Log (Arrow & " REQUEST_NV_READ_ITEM");
            elsif Msg = 16#77000000# then
                Genode_Log.Log (Arrow & " REQUEST_NV_WRITE_ITEM");
            elsif Msg = 16#78000000# then
                Genode_Log.Log (Arrow & " REQUEST_NV_WRITE_CDMA_PRL");
            elsif Msg = 16#79000000# then
                Genode_Log.Log (Arrow & " REQUEST_NV_RESET_CONFIG");
            elsif Msg = 16#7a000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_UICC_SUBSCRIPTION");
            elsif Msg = 16#7b000000# then
                Genode_Log.Log (Arrow & " REQUEST_ALLOW_DATA");
            elsif Msg = 16#7c000000# then
                Genode_Log.Log (Arrow & " REQUEST_GET_HARDWARE_CONFIG");
            elsif Msg = 16#7d000000# then
                Genode_Log.Log (Arrow & " REQUEST_SIM_AUTHENTICATION");
            elsif Msg = 16#7e000000# then
                Genode_Log.Log (Arrow & " REQUEST_GET_DC_RT_INFO");
            elsif Msg = 16#7f000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_DC_RT_INFO_RATE");
            elsif Msg = 16#80000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_DATA_PROFILE");
            elsif Msg = 16#81000000# then
                Genode_Log.Log (Arrow & " REQUEST_SHUTDOWN");
            elsif Msg = 16#82000000# then
                Genode_Log.Log (Arrow & " REQUEST_GET_RADIO_CAPABILITY");
            elsif Msg = 16#83000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_RADIO_CAPABILITY");
            elsif Msg = 16#84000000# then
                Genode_Log.Log (Arrow & " REQUEST_START_LCE");
            elsif Msg = 16#85000000# then
                Genode_Log.Log (Arrow & " REQUEST_STOP_LCE");
            elsif Msg = 16#86000000# then
                Genode_Log.Log (Arrow & " REQUEST_PULL_LCEDATA");
            elsif Msg = 16#87000000# then
                Genode_Log.Log (Arrow & " REQUEST_GET_ACTIVITY_INFO");
            elsif Msg = 16#88000000# then
                Genode_Log.Log (Arrow & " REQUEST_SET_CARRIER_RESTRICTIONS");
            elsif Msg = 16#89000000# then
                Genode_Log.Log (Arrow & " REQUEST_GET_CARRIER_RESTRICTIONS");
            elsif Msg = 16#20030000# then
                Genode_Log.Log (Arrow & " RESPONSE_ACKNOWLEDGEMENT");
            elsif Msg = 16#e8030000# then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_BASE | UNSOL_RESPONSE_RADIO_STATE_CHANGED");
            elsif Msg = 16#e9030000# then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_CALL_STATE_CHANGED");
            elsif Msg = 16#ea030000# then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_VOICE_NETWORK_STATE_CHANGED");
            elsif Msg = 16#eb030000# then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_NEW_SMS");
            elsif Msg = 16#ec030000# then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_NEW_SMS_STATUS_REPORT");
            elsif Msg = 16#ed030000# then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_NEW_SMS_ON_SIM");
            elsif Msg = 16#ee030000# then
                Genode_Log.Log (Arrow & " UNSOL_ON_USSD");
            elsif Msg = 16#ef030000# then
                Genode_Log.Log (Arrow & " UNSOL_ON_USSD_REQUEST");
            elsif Msg = 16#f0030000# then
                Genode_Log.Log (Arrow & " UNSOL_NITZ_TIME_RECEIVED");
            elsif Msg = 16#f1030000# then
                Genode_Log.Log (Arrow & " UNSOL_SIGNAL_STRENGTH");
            elsif Msg = 16#f2030000# then
                Genode_Log.Log (Arrow & " UNSOL_DATA_CALL_LIST_CHANGED");
            elsif Msg = 16#f3030000# then
                Genode_Log.Log (Arrow & " UNSOL_SUPP_SVC_NOTIFICATION");
            elsif Msg = 16#f4030000# then
                Genode_Log.Log (Arrow & " UNSOL_STK_SESSION_END");
            elsif Msg = 16#f5030000# then
                Genode_Log.Log (Arrow & " UNSOL_STK_PROACTIVE_COMMAND");
            elsif Msg = 16#f6030000# then
                Genode_Log.Log (Arrow & " UNSOL_STK_EVENT_NOTIFY");
            elsif Msg = 16#f7030000# then
                Genode_Log.Log (Arrow & " UNSOL_STK_CALL_SETUP");
            elsif Msg = 16#f8030000# then
                Genode_Log.Log (Arrow & " UNSOL_SIM_SMS_STORAGE_FULL");
            elsif Msg = 16#f9030000# then
                Genode_Log.Log (Arrow & " UNSOL_SIM_REFRESH");
            elsif Msg = 16#fa030000# then
                Genode_Log.Log (Arrow & " UNSOL_CALL_RING");
            elsif Msg = 16#fb030000# then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_SIM_STATUS_CHANGED");
            elsif Msg = 16#fc030000# then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_CDMA_NEW_SMS");
            elsif Msg = 16#fd030000# then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_NEW_BROADCAST_SMS");
            elsif Msg = 16#fe030000# then
                Genode_Log.Log (Arrow & " UNSOL_CDMA_RUIM_SMS_STORAGE_FULL");
            elsif Msg = 16#ff030000# then
                Genode_Log.Log (Arrow & " UNSOL_RESTRICTED_STATE_CHANGED");
            elsif Msg = 16#00040000# then
                Genode_Log.Log (Arrow & " UNSOL_ENTER_EMERGENCY_CALLBACK_MODE");
            elsif Msg = 16#01040000# then
                Genode_Log.Log (Arrow & " UNSOL_CDMA_CALL_WAITING");
            elsif Msg = 16#02040000# then
                Genode_Log.Log (Arrow & " UNSOL_CDMA_OTA_PROVISION_STATUS");
            elsif Msg = 16#03040000# then
                Genode_Log.Log (Arrow & " UNSOL_CDMA_INFO_REC");
            elsif Msg = 16#04040000# then
                Genode_Log.Log (Arrow & " UNSOL_OEM_HOOK_RAW");
            elsif Msg = 16#05040000# then
                Genode_Log.Log (Arrow & " UNSOL_RINGBACK_TONE");
            elsif Msg = 16#06040000# then
                Genode_Log.Log (Arrow & " UNSOL_RESEND_INCALL_MUTE");
            elsif Msg = 16#07040000# then
                Genode_Log.Log (Arrow & " UNSOL_CDMA_SUBSCRIPTION_SOURCE_CHANGED");
            elsif Msg = 16#08040000# then
                Genode_Log.Log (Arrow & " UNSOL_CDMA_PRL_CHANGED");
            elsif Msg = 16#09040000# then
                Genode_Log.Log (Arrow & " UNSOL_EXIT_EMERGENCY_CALLBACK_MODE");
            elsif Msg = 16#0a040000# then
                Genode_Log.Log (Arrow & " UNSOL_RIL_CONNECTED");
            elsif Msg = 16#0b040000# then
                Genode_Log.Log (Arrow & " UNSOL_VOICE_RADIO_TECH_CHANGED");
            elsif Msg = 16#0c040000# then
                Genode_Log.Log (Arrow & " UNSOL_CELL_INFO_LIST");
            elsif Msg = 16#0d040000# then
                Genode_Log.Log (Arrow & " UNSOL_RESPONSE_IMS_NETWORK_STATE_CHANGED");
            elsif Msg = 16#0e040000# then
                Genode_Log.Log (Arrow & " UNSOL_UICC_SUBSCRIPTION_STATUS_CHANGED");
            elsif Msg = 16#0f040000# then
                Genode_Log.Log (Arrow & " UNSOL_SRVCC_STATE_NOTIFY");
            elsif Msg = 16#10040000# then
                Genode_Log.Log (Arrow & " UNSOL_HARDWARE_CONFIG_CHANGED");
            elsif Msg = 16#11040000# then
                Genode_Log.Log (Arrow & " UNSOL_DC_RT_INFO_CHANGED");
            elsif Msg = 16#12040000# then
                Genode_Log.Log (Arrow & " UNSOL_RADIO_CAPABILITY");
            elsif Msg = 16#13040000# then
                Genode_Log.Log (Arrow & " UNSOL_ON_SS");
            elsif Msg = 16#14040000# then
                Genode_Log.Log (Arrow & " UNSOL_STK_CC_ALPHA_NOTIFY");
            elsif Msg = 16#15040000# then
                Genode_Log.Log (Arrow & " UNSOL_LCEDATA_RECV");
            elsif Msg = 16#16040000# then
                Genode_Log.Log (Arrow & " UNSOL_PCO_DATA");
            else
                Genode_Log.Log (Arrow &
                                  " UNKNOWN: " &
                                  Fw_Types.Image (Source.RIL_Header.ID) &
                                  " TOKEN: " &
                                  Fw_Types.Image (Source.RIL_Header.Token_Event));
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
       Destination_Buffer :    out Fw_Types.Buffer;
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
