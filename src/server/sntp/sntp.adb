with Libc;
with Libc_Types;
with Sntp_Types;
with System;
use all type Libc_Types.Addrinfo;
use all type Sntp_Types.Timestamp;
use all type System.Address;

package body Sntp
with
SPARK_Mode => On
is

    pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");

    function C_Connect (
                        Host   : System.Address;
                        Length : Integer;
                        Ai     : Libc_Types.Addrinfo
                       ) return Libc_Types.Socket
      with
        SPARK_Mode => Off
    is
        S_Host : String (1 .. Length);
        for S_Host'Address use Host;
        Sock   : Libc_Types.Socket := -42;
    begin
        if Host /= System.Null_Address then
            Sock := Connect (S_Host, Ai);
        end if;
        return Sock;
    end C_Connect;

    function Connect (
                      Host : String;
                      Ai   : Libc_Types.Addrinfo
                     ) return Libc_Types.Socket
    is
        Sock : Libc_Types.Socket := -42;
    begin
        if Ai /= Libc_Types.Null_Address then
            if Libc.Getaddrinfo (Host, Ai) = 0 then
                Sock := Libc.Getsocket (Ai);
            end if;
        end if;
        return Sock;
    end Connect;

    function C_Get_Time (
                         Sock    : Libc_Types.Socket;
                         Ai      : Libc_Types.Addrinfo;
                         Timeout : Long_Integer
                        ) return Sntp_Types.Timestamp
      with
        SPARK_Mode => Off
    is
        Ts : Sntp_Types.Timestamp;
    begin
        Get_Time (Sock, Ai, Timeout, Ts);
        return Ts;
    end C_Get_Time;

    procedure Get_Time (
                        Sock    : Libc_Types.Socket;
                        Ai      : Libc_Types.Addrinfo;
                        Timeout : Long_Integer;
                        Ts      : out Sntp_Types.Timestamp
                       )
    is
        procedure Flush (
                         S : Libc_Types.Socket;
                         A : Libc_Types.Addrinfo
                        );
        procedure Flush (
                         S : Libc_Types.Socket;
                         A : Libc_Types.Addrinfo
                        )
        is
            Msg_Size : constant Long_Integer := 48;
            Received : Long_Integer := Msg_Size;
            Msg      : Sntp_Types.Message;
        begin
            while Received >= Msg_Size loop
                Libc.Recv (S, Msg, A, 0, Received);
                Recv_Buffer := Msg;
            end loop;
        end Flush;

        Msg      : Sntp_Types.Message := (Leap => Sntp_Types.AlarmCondition,
                                          Version => 2, Mode => Sntp_Types.Client,
                                          Poll => 4, Precision => 0, Root_Delay => 0,
                                          Root_Dispersion => 0, Stratum => 0, others => 0);
        Sent     : Long_Integer;
        Received : Long_Integer;
    begin
        Ts := 0;
        if Sock >= 0 and Ai /= Libc_Types.Null_Address then
            Flush (Sock, Ai);
            Libc.Send (Sock, Msg, Ai, Sent);
            if Sent > 0 then
                Libc.Recv (Sock, Msg, Ai, Timeout, Received);
                if Received > 0 and then Sntp_Types.Valid_Sntp_Timestamp (Msg.Transmit_Timestamp_Sec) then
                    Ts := Msg.Transmit_Timestamp_Sec - 2208988800;
                end if;
            end if;
        end if;
    end Get_Time;

end Sntp;
