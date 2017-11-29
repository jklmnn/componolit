with fw_log;
with fw_types;
use all type fw_types.Nibble;
use all type fw_types.Byte;
use all type fw_types.Buffer;
use all type fw_types.Direction;

package body baseband_fw is

    procedure filter(
                     dest: System.Address;
                     src: System.Address;
                     dest_size: Integer;
                     src_size: Integer;
                     dir: Integer) 
    is
        dest_buf: fw_types.Buffer (0 .. dest_size);
        src_buf: fw_types.Buffer (0 .. src_size);
        src_packet: fw_types.packet;
        for dest_buf'Address use dest;
        for src_buf'Address use src;
        for src_packet'Address use src;
        packet_status: fw_types.Status := analyze(src_packet, fw_types.Direction'Val(dir));
    begin
        copy(dest_buf, src_buf);
    end;

    procedure copy (
                    dest: out fw_types.Buffer;
                    src: in fw_types.Buffer) with
      SPARK_Mode is
    begin
        dest := src;
    end;

    function analyze (
                      source: in fw_types.Packet;
                      dir: in fw_types.Direction) return fw_types.Status with
      SPARK_Mode
    is  
        arrow: fw_log.Arrow := fw_log.directed_arrow(dir);
        ril_id: String(1..8);
        token : String(1..8);
        msg : fw_types.Buffer (0 .. 3);
    begin
        if source.ip_header.Protocol = proto and then
          (source.udp_header.source = port and source.udp_header.destination = port) then
            if source.ril_packet.Length = ril_length then
                if source.ril_packet.ID = ril_setup then
                    fw_log.log(arrow & " SETUP");
                elsif source.ril_packet.ID = ril_teardown then
                    fw_log.log(arrow & " TEARDOWN");
                end if;
            else
                msg := source.ril_packet.id;
                if msg = fw_types.Buffer'((0,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_SIM_STATUS");
                elsif msg = fw_types.Buffer'((0,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ENTER_SIM_PIN");
                elsif msg = fw_types.Buffer'((0,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ENTER_SIM_PUK");
                elsif msg = fw_types.Buffer'((0,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ENTER_SIM_PIN2");
                elsif msg = fw_types.Buffer'((0,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ENTER_SIM_PUK2");
                elsif msg = fw_types.Buffer'((0,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CHANGE_SIM_PIN");
                elsif msg = fw_types.Buffer'((0,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CHANGE_SIM_PIN2");
                elsif msg = fw_types.Buffer'((0,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ENTER_NETWORK_DEPERSONALIZATION");
                elsif msg = fw_types.Buffer'((0,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_CURRENT_CALLS");
                elsif msg = fw_types.Buffer'((0,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DIAL");
                elsif msg = fw_types.Buffer'((0,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_IMSI");
                elsif msg = fw_types.Buffer'((0,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_HANGUP");
                elsif msg = fw_types.Buffer'((0,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_HANGUP_WAITING_OR_BACKGROUND");
                elsif msg = fw_types.Buffer'((0,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_HANGUP_FOREGROUND_RESUME_BACKGROUND");
                elsif msg = fw_types.Buffer'((0,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SWITCH_WAITING_OR_HOLDING_AND_ACTIVE");
                elsif msg = fw_types.Buffer'((0,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SWITCH_HOLDING_AND_ACTIVE");
                elsif msg = fw_types.Buffer'((1,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CONFERENCE");
                elsif msg = fw_types.Buffer'((1,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_UDUB");
                elsif msg = fw_types.Buffer'((1,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_LAST_CALL_FAIL_CAUSE");
                elsif msg = fw_types.Buffer'((1,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SIGNAL_STRENGTH");
                elsif msg = fw_types.Buffer'((1,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_VOICE_REGISTRATION_STATE");
                elsif msg = fw_types.Buffer'((1,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DATA_REGISTRATION_STATE");
                elsif msg = fw_types.Buffer'((1,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_OPERATOR");
                elsif msg = fw_types.Buffer'((1,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_RADIO_POWER");
                elsif msg = fw_types.Buffer'((1,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DTMF");
                elsif msg = fw_types.Buffer'((1,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SEND_SMS");
                elsif msg = fw_types.Buffer'((1,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SEND_SMS_EXPECT_MORE");
                elsif msg = fw_types.Buffer'((1,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SETUP_DATA_CALL");
                elsif msg = fw_types.Buffer'((1,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SIM_IO");
                elsif msg = fw_types.Buffer'((1,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SEND_USSD");
                elsif msg = fw_types.Buffer'((1,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CANCEL_USSD");
                elsif msg = fw_types.Buffer'((1,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_CLIR");
                elsif msg = fw_types.Buffer'((2,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_CLIR");
                elsif msg = fw_types.Buffer'((2,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_QUERY_CALL_FORWARD_STATUS");
                elsif msg = fw_types.Buffer'((2,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_CALL_FORWARD");
                elsif msg = fw_types.Buffer'((2,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_QUERY_CALL_WAITING");
                elsif msg = fw_types.Buffer'((2,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_CALL_WAITING");
                elsif msg = fw_types.Buffer'((2,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SMS_ACKNOWLEDGE");
                elsif msg = fw_types.Buffer'((2,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_IMEI");
                elsif msg = fw_types.Buffer'((2,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_IMEISV");
                elsif msg = fw_types.Buffer'((2,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ANSWER");
                elsif msg = fw_types.Buffer'((2,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DEACTIVATE_DATA_CALL");
                elsif msg = fw_types.Buffer'((2,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_QUERY_FACILITY_LOCK");
                elsif msg = fw_types.Buffer'((2,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_FACILITY_LOCK");
                elsif msg = fw_types.Buffer'((2,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CHANGE_BARRING_PASSWORD");
                elsif msg = fw_types.Buffer'((2,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_QUERY_NETWORK_SELECTION_MODE");
                elsif msg = fw_types.Buffer'((2,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_NETWORK_SELECTION_AUTOMATIC");
                elsif msg = fw_types.Buffer'((2,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_NETWORK_SELECTION_MANUAL");
                elsif msg = fw_types.Buffer'((3,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_QUERY_AVAILABLE_NETWORKS");
                elsif msg = fw_types.Buffer'((3,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DTMF_START");
                elsif msg = fw_types.Buffer'((3,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DTMF_STOP");
                elsif msg = fw_types.Buffer'((3,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_BASEBAND_VERSION");
                elsif msg = fw_types.Buffer'((3,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SEPARATE_CONNECTION");
                elsif msg = fw_types.Buffer'((3,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_MUTE");
                elsif msg = fw_types.Buffer'((3,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_MUTE");
                elsif msg = fw_types.Buffer'((3,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_QUERY_CLIP");
                elsif msg = fw_types.Buffer'((3,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_LAST_DATA_CALL_FAIL_CAUSE");
                elsif msg = fw_types.Buffer'((3,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DATA_CALL_LIST");
                elsif msg = fw_types.Buffer'((3,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_RESET_RADIO");
                elsif msg = fw_types.Buffer'((3,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_OEM_HOOK_RAW");
                elsif msg = fw_types.Buffer'((3,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_OEM_HOOK_STRINGS");
                elsif msg = fw_types.Buffer'((3,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SCREEN_STATE");
                elsif msg = fw_types.Buffer'((3,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_SUPP_SVC_NOTIFICATION");
                elsif msg = fw_types.Buffer'((3,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_WRITE_SMS_TO_SIM");
                elsif msg = fw_types.Buffer'((4,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DELETE_SMS_ON_SIM");
                elsif msg = fw_types.Buffer'((4,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_BAND_MODE");
                elsif msg = fw_types.Buffer'((4,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_QUERY_AVAILABLE_BAND_MODE");
                elsif msg = fw_types.Buffer'((4,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STK_GET_PROFILE");
                elsif msg = fw_types.Buffer'((4,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STK_SET_PROFILE");
                elsif msg = fw_types.Buffer'((4,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STK_SEND_ENVELOPE_COMMAND");
                elsif msg = fw_types.Buffer'((4,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STK_SEND_TERMINAL_RESPONSE");
                elsif msg = fw_types.Buffer'((4,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STK_HANDLE_CALL_SETUP_REQUESTED_FROM_SIM");
                elsif msg = fw_types.Buffer'((4,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_EXPLICIT_CALL_TRANSFER");
                elsif msg = fw_types.Buffer'((4,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_PREFERRED_NETWORK_TYPE");
                elsif msg = fw_types.Buffer'((4,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_PREFERRED_NETWORK_TYPE");
                elsif msg = fw_types.Buffer'((4,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_NEIGHBORING_CELL_IDS");
                elsif msg = fw_types.Buffer'((4,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_LOCATION_UPDATES");
                elsif msg = fw_types.Buffer'((4,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_SET_SUBSCRIPTION_SOURCE");
                elsif msg = fw_types.Buffer'((4,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_SET_ROAMING_PREFERENCE");
                elsif msg = fw_types.Buffer'((4,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_QUERY_ROAMING_PREFERENCE");
                elsif msg = fw_types.Buffer'((5,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_TTY_MODE");
                elsif msg = fw_types.Buffer'((5,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_QUERY_TTY_MODE");
                elsif msg = fw_types.Buffer'((5,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_SET_PREFERRED_VOICE_PRIVACY_MODE");
                elsif msg = fw_types.Buffer'((5,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_QUERY_PREFERRED_VOICE_PRIVACY_MODE");
                elsif msg = fw_types.Buffer'((5,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_FLASH");
                elsif msg = fw_types.Buffer'((5,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_BURST_DTMF");
                elsif msg = fw_types.Buffer'((5,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_VALIDATE_AND_WRITE_AKEY");
                elsif msg = fw_types.Buffer'((5,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_SEND_SMS");
                elsif msg = fw_types.Buffer'((5,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_SMS_ACKNOWLEDGE");
                elsif msg = fw_types.Buffer'((5,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GSM_GET_BROADCAST_SMS_CONFIG");
                elsif msg = fw_types.Buffer'((5,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GSM_SET_BROADCAST_SMS_CONFIG");
                elsif msg = fw_types.Buffer'((5,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GSM_SMS_BROADCAST_ACTIVATION");
                elsif msg = fw_types.Buffer'((5,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_GET_BROADCAST_SMS_CONFIG");
                elsif msg = fw_types.Buffer'((5,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_SET_BROADCAST_SMS_CONFIG");
                elsif msg = fw_types.Buffer'((5,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_SMS_BROADCAST_ACTIVATION");
                elsif msg = fw_types.Buffer'((5,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_SUBSCRIPTION");
                elsif msg = fw_types.Buffer'((6,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_WRITE_SMS_TO_RUIM");
                elsif msg = fw_types.Buffer'((6,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_DELETE_SMS_ON_RUIM");
                elsif msg = fw_types.Buffer'((6,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DEVICE_IDENTITY");
                elsif msg = fw_types.Buffer'((6,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_EXIT_EMERGENCY_CALLBACK_MODE");
                elsif msg = fw_types.Buffer'((6,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_SMSC_ADDRESS");
                elsif msg = fw_types.Buffer'((6,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_SMSC_ADDRESS");
                elsif msg = fw_types.Buffer'((6,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_REPORT_SMS_MEMORY_STATUS");
                elsif msg = fw_types.Buffer'((6,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_REPORT_STK_SERVICE_IS_RUNNING");
                elsif msg = fw_types.Buffer'((6,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_GET_SUBSCRIPTION_SOURCE");
                elsif msg = fw_types.Buffer'((6,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ISIM_AUTHENTICATION");
                elsif msg = fw_types.Buffer'((6,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ACKNOWLEDGE_INCOMING_GSM_SMS_WITH_PDU");
                elsif msg = fw_types.Buffer'((6,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STK_SEND_ENVELOPE_WITH_STATUS");
                elsif msg = fw_types.Buffer'((6,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_VOICE_RADIO_TECH");
                elsif msg = fw_types.Buffer'((6,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_CELL_INFO_LIST");
                elsif msg = fw_types.Buffer'((6,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_UNSOL_CELL_INFO_LIST_RATE");
                elsif msg = fw_types.Buffer'((6,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_INITIAL_ATTACH_APN");
                elsif msg = fw_types.Buffer'((7,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_IMS_REGISTRATION_STATE");
                elsif msg = fw_types.Buffer'((7,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_IMS_SEND_SMS");
                elsif msg = fw_types.Buffer'((7,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SIM_TRANSMIT_APDU_BASIC");
                elsif msg = fw_types.Buffer'((7,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SIM_OPEN_CHANNEL");
                elsif msg = fw_types.Buffer'((7,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SIM_CLOSE_CHANNEL");
                elsif msg = fw_types.Buffer'((7,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SIM_TRANSMIT_APDU_CHANNEL");
                elsif msg = fw_types.Buffer'((7,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_NV_READ_ITEM");
                elsif msg = fw_types.Buffer'((7,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_NV_WRITE_ITEM");
                elsif msg = fw_types.Buffer'((7,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_NV_WRITE_CDMA_PRL");
                elsif msg = fw_types.Buffer'((7,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_NV_RESET_CONFIG");
                elsif msg = fw_types.Buffer'((7,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_UICC_SUBSCRIPTION");
                elsif msg = fw_types.Buffer'((7,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ALLOW_DATA");
                elsif msg = fw_types.Buffer'((7,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_HARDWARE_CONFIG");
                elsif msg = fw_types.Buffer'((7,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SIM_AUTHENTICATION");
                elsif msg = fw_types.Buffer'((7,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_DC_RT_INFO");
                elsif msg = fw_types.Buffer'((7,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_DC_RT_INFO_RATE");
                elsif msg = fw_types.Buffer'((8,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_DATA_PROFILE");
                elsif msg = fw_types.Buffer'((8,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SHUTDOWN");
                elsif msg = fw_types.Buffer'((8,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_RADIO_CAPABILITY");
                elsif msg = fw_types.Buffer'((8,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_RADIO_CAPABILITY");
                elsif msg = fw_types.Buffer'((8,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_START_LCE");
                elsif msg = fw_types.Buffer'((8,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STOP_LCE");
                elsif msg = fw_types.Buffer'((8,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_PULL_LCEDATA");
                elsif msg = fw_types.Buffer'((8,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_ACTIVITY_INFO");
                elsif msg = fw_types.Buffer'((8,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_CARRIER_RESTRICTIONS");
                elsif msg = fw_types.Buffer'((8,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_CARRIER_RESTRICTIONS");
                elsif msg = fw_types.Buffer'((8,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SEND_DEVICE_STATE");
                elsif msg = fw_types.Buffer'((8,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_UNSOLICITED_RESPONSE_FILTER");
                elsif msg = fw_types.Buffer'((8,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_SIM_CARD_POWER");
                elsif msg = fw_types.Buffer'((8,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_CARRIER_INFO_IMSI_ENCRYPTION");
                elsif msg = fw_types.Buffer'((8,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_START_NETWORK_SCAN");
                elsif msg = fw_types.Buffer'((8,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STOP_NETWORK_SCAN");
                elsif msg = fw_types.Buffer'((9,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_START_KEEPALIVE");
                elsif msg = fw_types.Buffer'((9,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STOP_KEEPALIVE");
                elsif msg = fw_types.Buffer'((2,0),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " RESPONSE_ACKNOWLEDGEMENT");
                elsif msg = fw_types.Buffer'((14,8),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_BASE");
                elsif msg = fw_types.Buffer'((14,8),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_RADIO_STATE_CHANGED");
                elsif msg = fw_types.Buffer'((14,9),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_CALL_STATE_CHANGED");
                elsif msg = fw_types.Buffer'((14,10),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_VOICE_NETWORK_STATE_CHANGED");
                elsif msg = fw_types.Buffer'((14,11),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_NEW_SMS");
                elsif msg = fw_types.Buffer'((14,12),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_NEW_SMS_STATUS_REPORT");
                elsif msg = fw_types.Buffer'((14,13),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_NEW_SMS_ON_SIM");
                elsif msg = fw_types.Buffer'((14,14),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_ON_USSD");
                elsif msg = fw_types.Buffer'((14,15),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_ON_USSD_REQUEST");
                elsif msg = fw_types.Buffer'((15,0),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_NITZ_TIME_RECEIVED");
                elsif msg = fw_types.Buffer'((15,1),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_SIGNAL_STRENGTH");
                elsif msg = fw_types.Buffer'((15,2),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_DATA_CALL_LIST_CHANGED");
                elsif msg = fw_types.Buffer'((15,3),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_SUPP_SVC_NOTIFICATION");
                elsif msg = fw_types.Buffer'((15,4),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_STK_SESSION_END");
                elsif msg = fw_types.Buffer'((15,5),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_STK_PROACTIVE_COMMAND");
                elsif msg = fw_types.Buffer'((15,6),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_STK_EVENT_NOTIFY");
                elsif msg = fw_types.Buffer'((15,7),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_STK_CALL_SETUP");
                elsif msg = fw_types.Buffer'((15,8),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_SIM_SMS_STORAGE_FULL");
                elsif msg = fw_types.Buffer'((15,9),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_SIM_REFRESH");
                elsif msg = fw_types.Buffer'((15,10),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CALL_RING");
                elsif msg = fw_types.Buffer'((15,11),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_SIM_STATUS_CHANGED");
                elsif msg = fw_types.Buffer'((15,12),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_CDMA_NEW_SMS");
                elsif msg = fw_types.Buffer'((15,13),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_NEW_BROADCAST_SMS");
                elsif msg = fw_types.Buffer'((15,14),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CDMA_RUIM_SMS_STORAGE_FULL");
                elsif msg = fw_types.Buffer'((15,15),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESTRICTED_STATE_CHANGED");
                elsif msg = fw_types.Buffer'((0,0),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_ENTER_EMERGENCY_CALLBACK_MODE");
                elsif msg = fw_types.Buffer'((0,1),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CDMA_CALL_WAITING");
                elsif msg = fw_types.Buffer'((0,2),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CDMA_OTA_PROVISION_STATUS");
                elsif msg = fw_types.Buffer'((0,3),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CDMA_INFO_REC");
                elsif msg = fw_types.Buffer'((0,4),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_OEM_HOOK_RAW");
                elsif msg = fw_types.Buffer'((0,5),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RINGBACK_TONE");
                elsif msg = fw_types.Buffer'((0,6),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESEND_INCALL_MUTE");
                elsif msg = fw_types.Buffer'((0,7),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CDMA_SUBSCRIPTION_SOURCE_CHANGED");
                elsif msg = fw_types.Buffer'((0,8),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CDMA_PRL_CHANGED");
                elsif msg = fw_types.Buffer'((0,9),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_EXIT_EMERGENCY_CALLBACK_MODE");
                elsif msg = fw_types.Buffer'((0,10),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RIL_CONNECTED");
                elsif msg = fw_types.Buffer'((0,11),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_VOICE_RADIO_TECH_CHANGED");
                elsif msg = fw_types.Buffer'((0,12),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CELL_INFO_LIST");
                elsif msg = fw_types.Buffer'((0,13),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_IMS_NETWORK_STATE_CHANGED");
                elsif msg = fw_types.Buffer'((0,14),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_UICC_SUBSCRIPTION_STATUS_CHANGED");
                elsif msg = fw_types.Buffer'((0,15),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_SRVCC_STATE_NOTIFY");
                elsif msg = fw_types.Buffer'((1,0),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_HARDWARE_CONFIG_CHANGED");
                elsif msg = fw_types.Buffer'((1,1),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_DC_RT_INFO_CHANGED");
                elsif msg = fw_types.Buffer'((1,2),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RADIO_CAPABILITY");
                elsif msg = fw_types.Buffer'((1,3),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_ON_SS");
                elsif msg = fw_types.Buffer'((1,4),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_STK_CC_ALPHA_NOTIFY");
                elsif msg = fw_types.Buffer'((1,5),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_LCEDATA_RECV");
                elsif msg = fw_types.Buffer'((1,6),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_PCO_DATA");
                elsif msg = fw_types.Buffer'((1,7),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_MODEM_RESTART");
                elsif msg = fw_types.Buffer'((1,8),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CARRIER_INFO_IMSI_ENCRYPTION");
                elsif msg = fw_types.Buffer'((1,9),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_NETWORK_SCAN_RESULT");
                elsif msg = fw_types.Buffer'((1,10),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_KEEPALIVE_STATUS");
                elsif msg = fw_types.Buffer'((0,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " RESPONSE");
                else
                    fw_log.hex_dump(source.ril_packet.id, ril_id);
                    fw_log.hex_dump(source.ril_packet.token_event, token);
                    fw_log.log (arrow & " UNKNOWN: " & ril_id & " TOKEN: " & token);
                end if;
            end if;
        end if;
        return fw_types.ACCEPTED;
    end;

end baseband_fw;
