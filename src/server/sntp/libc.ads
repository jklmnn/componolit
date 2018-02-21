with sntp_types;
with libc_types;

package libc
with
SPARK_Mode => On
is

    function getaddrinfo(Address : String; Ai : libc_types.Addrinfo) return Integer
      with
        Pre => Address'Last < Integer'Last and
        libc_types."/="(Ai, libc_types.Null_Address);

    function getsocket(Ai : libc_types.Addrinfo) return libc_types.Socket
      with
        Pre => libc_types."/="(Ai, libc_types.Null_Address);

    procedure send(Sock : libc_types.Socket; Msg : sntp_types.Message;
                   Ai : libc_types.Addrinfo; Sent : out Long_Integer)
      with
        Pre => libc_types.">="(Sock, 0) and
      libc_types."/="(Ai, libc_types.Null_Address);

    procedure recv(Sock : libc_types.Socket; Msg : out sntp_types.Message;
                   Ai : libc_types.Addrinfo; Timeout : Long_Integer; Received : out Long_Integer)
      with
        Pre => libc_types.">="(Sock, 0) and
      libc_types."/="(Ai, libc_types.Null_Address);

end libc;
