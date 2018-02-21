with System;
with libc_types;
with sntp_types;

use all type libc_types.Socket;

package sntp
with
    SPARK_Mode => On
is

    function c_connect(Host : System.Address; Length : Integer; Ai : libc_types.Addrinfo)
                       return libc_types.Socket;
    function connect(Host : String; Ai : libc_types.Addrinfo) return libc_types.Socket
      with
        Pre => Host'Last < Integer'Last,
        Depends => (connect'Result => (Host, Ai));

    function c_get_time(Sock : libc_types.Socket; Ai : libc_types.Addrinfo; Timeout : Long_Integer)
                       return sntp_types.Timestamp;
    
    procedure get_time(Sock : libc_types.Socket; Ai : libc_types.Addrinfo; Timeout : Long_Integer;
                       Ts : out sntp_types.Timestamp)
      with Depends => (Ts => (Sock, Ai, Timeout), Recv_Buffer => +(Sock, Ai));
    
    Recv_Buffer : sntp_types.Message;
    
    pragma Volatile(Recv_Buffer);

end sntp;
