with libc;
with libc_types;
use all type libc_types.Addrinfo;

package body sntp
with
SPARK_Mode => On
is

    function c_connect(Host : System.Address; Length : Integer; Ai : libc_types.Addrinfo)
                       return libc_types.Socket
      with
        SPARK_Mode => Off
    is
        S_Host : String (1 .. Length);
        for S_Host'Address use Host;
        Sock : libc_types.Socket := -42;
    begin
        if System."/="(Host, System.Null_Address) then
            Sock := connect(S_Host, Ai);
        end if;
        return Sock;
    end c_connect;

    function connect(Host : String; Ai : libc_types.Addrinfo) return libc_types.Socket
    is
        Sock : libc_types.Socket := -42;
    begin
        if Ai /= libc_types.Null_Address then
            if libc.getaddrinfo(Host, Ai) = 0 then
                Sock := libc.getsocket(Ai);
            end if;
        end if;
        return Sock;
    end connect;

    function c_get_time(Sock : libc_types.Socket; Ai : libc_types.Addrinfo; Timeout : Long_Integer)
                        return sntp_types.Timestamp
      with
        SPARK_Mode => Off
    is
        Ts : sntp_types.Timestamp;
    begin
        get_time(Sock, Ai, Timeout, Ts);
        return Ts;
    end c_get_time;
    
    procedure get_time(Sock : libc_types.Socket; Ai : libc_types.Addrinfo; Timeout : Long_Integer;
                       Ts : out sntp_types.Timestamp)
    is
        procedure flush(Sock : libc_types.Socket; Ai : libc_types.Addrinfo)
        is
            Msg_Size : constant Long_Integer := 48;
            Received : Long_Integer := Msg_Size;
            Msg : sntp_types.Message;
        begin
            while Received >= Msg_Size loop
                libc.Recv(Sock, Msg, Ai, 0, Received);
                Recv_Buffer := Msg;
            end loop;
        end flush;
        
        Msg : sntp_types.Message := ( Leap => sntp_types.AlarmCondition,
                                      Version => 2, Mode => sntp_types.Client,
                                      Poll => 4, Precision => 0, Root_Delay => 0,
                                      Root_Dispersion => 0, Stratum => 0, others => 0);
        Sent : Long_Integer;
        Received : Long_Integer;
    begin
        Ts := 0;
        if Sock >= 0 and Ai /= libc_types.Null_Address then
            flush(Sock, Ai);
            libc.Send(Sock, Msg, Ai, Sent);
            if Sent > 0 then
                libc.Recv(Sock, Msg, Ai, Timeout, Received);
                if Received > 0 then
                    Ts := sntp_types.Unix_Epoch(Msg.Transmit_Timestamp_Sec);
                end if;
            end if;
        end if;
    end get_time;

end sntp;

