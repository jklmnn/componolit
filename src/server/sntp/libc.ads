with Sntp_Types;
with Libc_Types;
use all type Libc_Types.Addrinfo;
use all type Libc_Types.Socket;

package Libc
with
SPARK_Mode => On
is

    function Getaddrinfo (
                          Address : String;
                          Ai      : Libc_Types.Addrinfo
                         ) return Integer
      with
        Pre => Address'Last < Integer'Last and
        Ai /= Libc_Types.Null_Address;

    function Getsocket (
                        Ai : Libc_Types.Addrinfo
                       ) return Libc_Types.Socket
      with
        Pre => Ai /= Libc_Types.Null_Address;

    procedure Send (
                    Sock : Libc_Types.Socket;
                    Msg  : Sntp_Types.Message;
                    Ai   : Libc_Types.Addrinfo;
                    Sent : out Long_Integer
                   )
      with
        Pre => Sock >= 0 and
      Ai /= Libc_Types.Null_Address;

    procedure Recv (
                    Sock     : Libc_Types.Socket;
                    Msg      : out Sntp_Types.Message;
                    Ai       : Libc_Types.Addrinfo;
                    Timeout  : Long_Integer;
                    Received : out Long_Integer
                   )
      with
        Pre => Sock >= 0 and
      Ai /= Libc_Types.Null_Address;

end Libc;
