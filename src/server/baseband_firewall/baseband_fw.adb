with fw_log;
with fw_types;
use all type fw_types.Nibble;
use all type fw_types.Byte;
use all type fw_types.Buffer;

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
                if source.ril_packet.id = fw_types.Buffer'((0,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_SIM_STATUS");
                elsif source.ril_packet.id = fw_types.Buffer'((0,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ENTER_SIM_PIN");
                elsif source.ril_packet.id = fw_types.Buffer'((0,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ENTER_SIM_PUK");
                elsif source.ril_packet.id = fw_types.Buffer'((0,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ENTER_SIM_PIN2");
                elsif source.ril_packet.id = fw_types.Buffer'((0,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ENTER_SIM_PUK2");
                elsif source.ril_packet.id = fw_types.Buffer'((0,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CHANGE_SIM_PIN");
                elsif source.ril_packet.id = fw_types.Buffer'((0,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CHANGE_SIM_PIN2");
                elsif source.ril_packet.id = fw_types.Buffer'((0,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ENTER_NETWORK_DEPERSONALIZATION");
                elsif source.ril_packet.id = fw_types.Buffer'((0,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_CURRENT_CALLS");
                elsif source.ril_packet.id = fw_types.Buffer'((0,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DIAL");
                elsif source.ril_packet.id = fw_types.Buffer'((0,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_IMSI");
                elsif source.ril_packet.id = fw_types.Buffer'((0,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_HANGUP");
                elsif source.ril_packet.id = fw_types.Buffer'((0,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_HANGUP_WAITING_OR_BACKGROUND");
                elsif source.ril_packet.id = fw_types.Buffer'((0,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_HANGUP_FOREGROUND_RESUME_BACKGROUND");
                elsif source.ril_packet.id = fw_types.Buffer'((0,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SWITCH_WAITING_OR_HOLDING_AND_ACTIVE");
                elsif source.ril_packet.id = fw_types.Buffer'((0,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SWITCH_HOLDING_AND_ACTIVE");
                elsif source.ril_packet.id = fw_types.Buffer'((1,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CONFERENCE");
                elsif source.ril_packet.id = fw_types.Buffer'((1,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_UDUB");
                elsif source.ril_packet.id = fw_types.Buffer'((1,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_LAST_CALL_FAIL_CAUSE");
                elsif source.ril_packet.id = fw_types.Buffer'((1,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SIGNAL_STRENGTH");
                elsif source.ril_packet.id = fw_types.Buffer'((1,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_VOICE_REGISTRATION_STATE");
                elsif source.ril_packet.id = fw_types.Buffer'((1,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DATA_REGISTRATION_STATE");
                elsif source.ril_packet.id = fw_types.Buffer'((1,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_OPERATOR");
                elsif source.ril_packet.id = fw_types.Buffer'((1,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_RADIO_POWER");
                elsif source.ril_packet.id = fw_types.Buffer'((1,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DTMF");
                elsif source.ril_packet.id = fw_types.Buffer'((1,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SEND_SMS");
                elsif source.ril_packet.id = fw_types.Buffer'((1,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SEND_SMS_EXPECT_MORE");
                elsif source.ril_packet.id = fw_types.Buffer'((1,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SETUP_DATA_CALL");
                elsif source.ril_packet.id = fw_types.Buffer'((1,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SIM_IO");
                elsif source.ril_packet.id = fw_types.Buffer'((1,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SEND_USSD");
                elsif source.ril_packet.id = fw_types.Buffer'((1,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CANCEL_USSD");
                elsif source.ril_packet.id = fw_types.Buffer'((1,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_CLIR");
                elsif source.ril_packet.id = fw_types.Buffer'((2,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_CLIR");
                elsif source.ril_packet.id = fw_types.Buffer'((2,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_QUERY_CALL_FORWARD_STATUS");
                elsif source.ril_packet.id = fw_types.Buffer'((2,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_CALL_FORWARD");
                elsif source.ril_packet.id = fw_types.Buffer'((2,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_QUERY_CALL_WAITING");
                elsif source.ril_packet.id = fw_types.Buffer'((2,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_CALL_WAITING");
                elsif source.ril_packet.id = fw_types.Buffer'((2,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SMS_ACKNOWLEDGE");
                elsif source.ril_packet.id = fw_types.Buffer'((2,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_IMEI");
                elsif source.ril_packet.id = fw_types.Buffer'((2,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_IMEISV");
                elsif source.ril_packet.id = fw_types.Buffer'((2,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ANSWER");
                elsif source.ril_packet.id = fw_types.Buffer'((2,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DEACTIVATE_DATA_CALL");
                elsif source.ril_packet.id = fw_types.Buffer'((2,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_QUERY_FACILITY_LOCK");
                elsif source.ril_packet.id = fw_types.Buffer'((2,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_FACILITY_LOCK");
                elsif source.ril_packet.id = fw_types.Buffer'((2,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CHANGE_BARRING_PASSWORD");
                elsif source.ril_packet.id = fw_types.Buffer'((2,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_QUERY_NETWORK_SELECTION_MODE");
                elsif source.ril_packet.id = fw_types.Buffer'((2,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_NETWORK_SELECTION_AUTOMATIC");
                elsif source.ril_packet.id = fw_types.Buffer'((2,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_NETWORK_SELECTION_MANUAL");
                elsif source.ril_packet.id = fw_types.Buffer'((3,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_QUERY_AVAILABLE_NETWORKS");
                elsif source.ril_packet.id = fw_types.Buffer'((3,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DTMF_START");
                elsif source.ril_packet.id = fw_types.Buffer'((3,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DTMF_STOP");
                elsif source.ril_packet.id = fw_types.Buffer'((3,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_BASEBAND_VERSION");
                elsif source.ril_packet.id = fw_types.Buffer'((3,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SEPARATE_CONNECTION");
                elsif source.ril_packet.id = fw_types.Buffer'((3,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_MUTE");
                elsif source.ril_packet.id = fw_types.Buffer'((3,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_MUTE");
                elsif source.ril_packet.id = fw_types.Buffer'((3,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_QUERY_CLIP");
                elsif source.ril_packet.id = fw_types.Buffer'((3,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_LAST_DATA_CALL_FAIL_CAUSE");
                elsif source.ril_packet.id = fw_types.Buffer'((3,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DATA_CALL_LIST");
                elsif source.ril_packet.id = fw_types.Buffer'((3,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_RESET_RADIO");
                elsif source.ril_packet.id = fw_types.Buffer'((3,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_OEM_HOOK_RAW");
                elsif source.ril_packet.id = fw_types.Buffer'((3,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_OEM_HOOK_STRINGS");
                elsif source.ril_packet.id = fw_types.Buffer'((3,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SCREEN_STATE");
                elsif source.ril_packet.id = fw_types.Buffer'((3,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_SUPP_SVC_NOTIFICATION");
                elsif source.ril_packet.id = fw_types.Buffer'((3,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_WRITE_SMS_TO_SIM");
                elsif source.ril_packet.id = fw_types.Buffer'((4,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DELETE_SMS_ON_SIM");
                elsif source.ril_packet.id = fw_types.Buffer'((4,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_BAND_MODE");
                elsif source.ril_packet.id = fw_types.Buffer'((4,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_QUERY_AVAILABLE_BAND_MODE");
                elsif source.ril_packet.id = fw_types.Buffer'((4,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STK_GET_PROFILE");
                elsif source.ril_packet.id = fw_types.Buffer'((4,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STK_SET_PROFILE");
                elsif source.ril_packet.id = fw_types.Buffer'((4,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STK_SEND_ENVELOPE_COMMAND");
                elsif source.ril_packet.id = fw_types.Buffer'((4,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STK_SEND_TERMINAL_RESPONSE");
                elsif source.ril_packet.id = fw_types.Buffer'((4,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STK_HANDLE_CALL_SETUP_REQUESTED_FROM_SIM");
                elsif source.ril_packet.id = fw_types.Buffer'((4,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_EXPLICIT_CALL_TRANSFER");
                elsif source.ril_packet.id = fw_types.Buffer'((4,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_PREFERRED_NETWORK_TYPE");
                elsif source.ril_packet.id = fw_types.Buffer'((4,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_PREFERRED_NETWORK_TYPE");
                elsif source.ril_packet.id = fw_types.Buffer'((4,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_NEIGHBORING_CELL_IDS");
                elsif source.ril_packet.id = fw_types.Buffer'((4,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_LOCATION_UPDATES");
                elsif source.ril_packet.id = fw_types.Buffer'((4,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_SET_SUBSCRIPTION_SOURCE");
                elsif source.ril_packet.id = fw_types.Buffer'((4,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_SET_ROAMING_PREFERENCE");
                elsif source.ril_packet.id = fw_types.Buffer'((4,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_QUERY_ROAMING_PREFERENCE");
                elsif source.ril_packet.id = fw_types.Buffer'((5,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_TTY_MODE");
                elsif source.ril_packet.id = fw_types.Buffer'((5,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_QUERY_TTY_MODE");
                elsif source.ril_packet.id = fw_types.Buffer'((5,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_SET_PREFERRED_VOICE_PRIVACY_MODE");
                elsif source.ril_packet.id = fw_types.Buffer'((5,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_QUERY_PREFERRED_VOICE_PRIVACY_MODE");
                elsif source.ril_packet.id = fw_types.Buffer'((5,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_FLASH");
                elsif source.ril_packet.id = fw_types.Buffer'((5,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_BURST_DTMF");
                elsif source.ril_packet.id = fw_types.Buffer'((5,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_VALIDATE_AND_WRITE_AKEY");
                elsif source.ril_packet.id = fw_types.Buffer'((5,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_SEND_SMS");
                elsif source.ril_packet.id = fw_types.Buffer'((5,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_SMS_ACKNOWLEDGE");
                elsif source.ril_packet.id = fw_types.Buffer'((5,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GSM_GET_BROADCAST_SMS_CONFIG");
                elsif source.ril_packet.id = fw_types.Buffer'((5,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GSM_SET_BROADCAST_SMS_CONFIG");
                elsif source.ril_packet.id = fw_types.Buffer'((5,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GSM_SMS_BROADCAST_ACTIVATION");
                elsif source.ril_packet.id = fw_types.Buffer'((5,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_GET_BROADCAST_SMS_CONFIG");
                elsif source.ril_packet.id = fw_types.Buffer'((5,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_SET_BROADCAST_SMS_CONFIG");
                elsif source.ril_packet.id = fw_types.Buffer'((5,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_SMS_BROADCAST_ACTIVATION");
                elsif source.ril_packet.id = fw_types.Buffer'((5,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_SUBSCRIPTION");
                elsif source.ril_packet.id = fw_types.Buffer'((6,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_WRITE_SMS_TO_RUIM");
                elsif source.ril_packet.id = fw_types.Buffer'((6,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_DELETE_SMS_ON_RUIM");
                elsif source.ril_packet.id = fw_types.Buffer'((6,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_DEVICE_IDENTITY");
                elsif source.ril_packet.id = fw_types.Buffer'((6,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_EXIT_EMERGENCY_CALLBACK_MODE");
                elsif source.ril_packet.id = fw_types.Buffer'((6,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_SMSC_ADDRESS");
                elsif source.ril_packet.id = fw_types.Buffer'((6,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_SMSC_ADDRESS");
                elsif source.ril_packet.id = fw_types.Buffer'((6,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_REPORT_SMS_MEMORY_STATUS");
                elsif source.ril_packet.id = fw_types.Buffer'((6,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_REPORT_STK_SERVICE_IS_RUNNING");
                elsif source.ril_packet.id = fw_types.Buffer'((6,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_CDMA_GET_SUBSCRIPTION_SOURCE");
                elsif source.ril_packet.id = fw_types.Buffer'((6,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ISIM_AUTHENTICATION");
                elsif source.ril_packet.id = fw_types.Buffer'((6,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ACKNOWLEDGE_INCOMING_GSM_SMS_WITH_PDU");
                elsif source.ril_packet.id = fw_types.Buffer'((6,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STK_SEND_ENVELOPE_WITH_STATUS");
                elsif source.ril_packet.id = fw_types.Buffer'((6,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_VOICE_RADIO_TECH");
                elsif source.ril_packet.id = fw_types.Buffer'((6,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_CELL_INFO_LIST");
                elsif source.ril_packet.id = fw_types.Buffer'((6,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_UNSOL_CELL_INFO_LIST_RATE");
                elsif source.ril_packet.id = fw_types.Buffer'((6,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_INITIAL_ATTACH_APN");
                elsif source.ril_packet.id = fw_types.Buffer'((7,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_IMS_REGISTRATION_STATE");
                elsif source.ril_packet.id = fw_types.Buffer'((7,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_IMS_SEND_SMS");
                elsif source.ril_packet.id = fw_types.Buffer'((7,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SIM_TRANSMIT_APDU_BASIC");
                elsif source.ril_packet.id = fw_types.Buffer'((7,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SIM_OPEN_CHANNEL");
                elsif source.ril_packet.id = fw_types.Buffer'((7,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SIM_CLOSE_CHANNEL");
                elsif source.ril_packet.id = fw_types.Buffer'((7,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SIM_TRANSMIT_APDU_CHANNEL");
                elsif source.ril_packet.id = fw_types.Buffer'((7,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_NV_READ_ITEM");
                elsif source.ril_packet.id = fw_types.Buffer'((7,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_NV_WRITE_ITEM");
                elsif source.ril_packet.id = fw_types.Buffer'((7,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_NV_WRITE_CDMA_PRL");
                elsif source.ril_packet.id = fw_types.Buffer'((7,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_NV_RESET_CONFIG");
                elsif source.ril_packet.id = fw_types.Buffer'((7,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_UICC_SUBSCRIPTION");
                elsif source.ril_packet.id = fw_types.Buffer'((7,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_ALLOW_DATA");
                elsif source.ril_packet.id = fw_types.Buffer'((7,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_HARDWARE_CONFIG");
                elsif source.ril_packet.id = fw_types.Buffer'((7,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SIM_AUTHENTICATION");
                elsif source.ril_packet.id = fw_types.Buffer'((7,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_DC_RT_INFO");
                elsif source.ril_packet.id = fw_types.Buffer'((7,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_DC_RT_INFO_RATE");
                elsif source.ril_packet.id = fw_types.Buffer'((8,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_DATA_PROFILE");
                elsif source.ril_packet.id = fw_types.Buffer'((8,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SHUTDOWN");
                elsif source.ril_packet.id = fw_types.Buffer'((8,2),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_RADIO_CAPABILITY");
                elsif source.ril_packet.id = fw_types.Buffer'((8,3),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_RADIO_CAPABILITY");
                elsif source.ril_packet.id = fw_types.Buffer'((8,4),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_START_LCE");
                elsif source.ril_packet.id = fw_types.Buffer'((8,5),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STOP_LCE");
                elsif source.ril_packet.id = fw_types.Buffer'((8,6),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_PULL_LCEDATA");
                elsif source.ril_packet.id = fw_types.Buffer'((8,7),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_ACTIVITY_INFO");
                elsif source.ril_packet.id = fw_types.Buffer'((8,8),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_CARRIER_RESTRICTIONS");
                elsif source.ril_packet.id = fw_types.Buffer'((8,9),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_GET_CARRIER_RESTRICTIONS");
                elsif source.ril_packet.id = fw_types.Buffer'((8,10),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SEND_DEVICE_STATE");
                elsif source.ril_packet.id = fw_types.Buffer'((8,11),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_UNSOLICITED_RESPONSE_FILTER");
                elsif source.ril_packet.id = fw_types.Buffer'((8,12),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_SIM_CARD_POWER");
                elsif source.ril_packet.id = fw_types.Buffer'((8,13),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_SET_CARRIER_INFO_IMSI_ENCRYPTION");
                elsif source.ril_packet.id = fw_types.Buffer'((8,14),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_START_NETWORK_SCAN");
                elsif source.ril_packet.id = fw_types.Buffer'((8,15),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STOP_NETWORK_SCAN");
                elsif source.ril_packet.id = fw_types.Buffer'((9,0),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_START_KEEPALIVE");
                elsif source.ril_packet.id = fw_types.Buffer'((9,1),(0,0),(0,0),(0,0)) then fw_log.log (arrow & " REQUEST_STOP_KEEPALIVE");
                elsif source.ril_packet.id = fw_types.Buffer'((2,0),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " RESPONSE_ACKNOWLEDGEMENT");
                elsif source.ril_packet.id = fw_types.Buffer'((14,8),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_BASE");
                elsif source.ril_packet.id = fw_types.Buffer'((14,8),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_RADIO_STATE_CHANGED");
                elsif source.ril_packet.id = fw_types.Buffer'((14,9),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_CALL_STATE_CHANGED");
                elsif source.ril_packet.id = fw_types.Buffer'((14,10),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_VOICE_NETWORK_STATE_CHANGED");
                elsif source.ril_packet.id = fw_types.Buffer'((14,11),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_NEW_SMS");
                elsif source.ril_packet.id = fw_types.Buffer'((14,12),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_NEW_SMS_STATUS_REPORT");
                elsif source.ril_packet.id = fw_types.Buffer'((14,13),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_NEW_SMS_ON_SIM");
                elsif source.ril_packet.id = fw_types.Buffer'((14,14),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_ON_USSD");
                elsif source.ril_packet.id = fw_types.Buffer'((14,15),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_ON_USSD_REQUEST");
                elsif source.ril_packet.id = fw_types.Buffer'((15,0),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_NITZ_TIME_RECEIVED");
                elsif source.ril_packet.id = fw_types.Buffer'((15,1),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_SIGNAL_STRENGTH");
                elsif source.ril_packet.id = fw_types.Buffer'((15,2),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_DATA_CALL_LIST_CHANGED");
                elsif source.ril_packet.id = fw_types.Buffer'((15,3),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_SUPP_SVC_NOTIFICATION");
                elsif source.ril_packet.id = fw_types.Buffer'((15,4),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_STK_SESSION_END");
                elsif source.ril_packet.id = fw_types.Buffer'((15,5),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_STK_PROACTIVE_COMMAND");
                elsif source.ril_packet.id = fw_types.Buffer'((15,6),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_STK_EVENT_NOTIFY");
                elsif source.ril_packet.id = fw_types.Buffer'((15,7),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_STK_CALL_SETUP");
                elsif source.ril_packet.id = fw_types.Buffer'((15,8),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_SIM_SMS_STORAGE_FULL");
                elsif source.ril_packet.id = fw_types.Buffer'((15,9),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_SIM_REFRESH");
                elsif source.ril_packet.id = fw_types.Buffer'((15,10),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CALL_RING");
                elsif source.ril_packet.id = fw_types.Buffer'((15,11),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_SIM_STATUS_CHANGED");
                elsif source.ril_packet.id = fw_types.Buffer'((15,12),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_CDMA_NEW_SMS");
                elsif source.ril_packet.id = fw_types.Buffer'((15,13),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_NEW_BROADCAST_SMS");
                elsif source.ril_packet.id = fw_types.Buffer'((15,14),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CDMA_RUIM_SMS_STORAGE_FULL");
                elsif source.ril_packet.id = fw_types.Buffer'((15,15),(0,3),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESTRICTED_STATE_CHANGED");
                elsif source.ril_packet.id = fw_types.Buffer'((0,0),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_ENTER_EMERGENCY_CALLBACK_MODE");
                elsif source.ril_packet.id = fw_types.Buffer'((0,1),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CDMA_CALL_WAITING");
                elsif source.ril_packet.id = fw_types.Buffer'((0,2),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CDMA_OTA_PROVISION_STATUS");
                elsif source.ril_packet.id = fw_types.Buffer'((0,3),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CDMA_INFO_REC");
                elsif source.ril_packet.id = fw_types.Buffer'((0,4),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_OEM_HOOK_RAW");
                elsif source.ril_packet.id = fw_types.Buffer'((0,5),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RINGBACK_TONE");
                elsif source.ril_packet.id = fw_types.Buffer'((0,6),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESEND_INCALL_MUTE");
                elsif source.ril_packet.id = fw_types.Buffer'((0,7),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CDMA_SUBSCRIPTION_SOURCE_CHANGED");
                elsif source.ril_packet.id = fw_types.Buffer'((0,8),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CDMA_PRL_CHANGED");
                elsif source.ril_packet.id = fw_types.Buffer'((0,9),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_EXIT_EMERGENCY_CALLBACK_MODE");
                elsif source.ril_packet.id = fw_types.Buffer'((0,10),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RIL_CONNECTED");
                elsif source.ril_packet.id = fw_types.Buffer'((0,11),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_VOICE_RADIO_TECH_CHANGED");
                elsif source.ril_packet.id = fw_types.Buffer'((0,12),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CELL_INFO_LIST");
                elsif source.ril_packet.id = fw_types.Buffer'((0,13),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RESPONSE_IMS_NETWORK_STATE_CHANGED");
                elsif source.ril_packet.id = fw_types.Buffer'((0,14),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_UICC_SUBSCRIPTION_STATUS_CHANGED");
                elsif source.ril_packet.id = fw_types.Buffer'((0,15),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_SRVCC_STATE_NOTIFY");
                elsif source.ril_packet.id = fw_types.Buffer'((1,0),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_HARDWARE_CONFIG_CHANGED");
                elsif source.ril_packet.id = fw_types.Buffer'((1,1),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_DC_RT_INFO_CHANGED");
                elsif source.ril_packet.id = fw_types.Buffer'((1,2),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_RADIO_CAPABILITY");
                elsif source.ril_packet.id = fw_types.Buffer'((1,3),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_ON_SS");
                elsif source.ril_packet.id = fw_types.Buffer'((1,4),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_STK_CC_ALPHA_NOTIFY");
                elsif source.ril_packet.id = fw_types.Buffer'((1,5),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_LCEDATA_RECV");
                elsif source.ril_packet.id = fw_types.Buffer'((1,6),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_PCO_DATA");
                elsif source.ril_packet.id = fw_types.Buffer'((1,7),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_MODEM_RESTART");
                elsif source.ril_packet.id = fw_types.Buffer'((1,8),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_CARRIER_INFO_IMSI_ENCRYPTION");
                elsif source.ril_packet.id = fw_types.Buffer'((1,9),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_NETWORK_SCAN_RESULT");
                elsif source.ril_packet.id = fw_types.Buffer'((1,10),(0,4),(0,0),(0,0)) then fw_log.log (arrow & " UNSOL_KEEPALIVE_STATUS");
                else 
                    fw_log.hex_dump(source.ril_packet.id, ril_id);
                    fw_log.log(arrow & " UNKNOWN " & ril_id);
                end if;
            end if;
        end if;
        return fw_types.ACCEPTED;
    end;

end baseband_fw;
