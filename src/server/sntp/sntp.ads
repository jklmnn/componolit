with System;
with Libc_Types;
with Sntp_Types;

use all type Libc_Types.Socket;

package Sntp
with
SPARK_Mode => On
is

    function C_Connect (
                        Host   : System.Address;
                        Length : Integer;
                        Ai     : Libc_Types.Addrinfo
                       ) return Libc_Types.Socket;

    function Connect (
                      Host : String;
                      Ai   : Libc_Types.Addrinfo
                     ) return Libc_Types.Socket
      with
        Pre => Host'Last < Integer'Last,
        Depends => (Connect'Result => (Host, Ai));

    function C_Get_Time (
                         Sock    : Libc_Types.Socket;
                         Ai      : Libc_Types.Addrinfo;
                         Timeout : Long_Integer
                        ) return Sntp_Types.Timestamp;

    procedure Get_Time (
                        Sock    : Libc_Types.Socket;
                        Ai      : Libc_Types.Addrinfo;
                        Timeout : Long_Integer;
                        Ts      : out Sntp_Types.Timestamp
                       )
      with Depends => (Ts => (Sock, Ai, Timeout), Recv_Buffer =>+ (Sock, Ai));

    Recv_Buffer : Sntp_Types.Message;

    pragma Volatile (Recv_Buffer);

end Sntp;
