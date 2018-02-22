with System;

package Libc_Import
is

    type Unsigned_32 is mod 2**32;

    function Lc_Getaddrinfo (
                             Addr : System.Address;
                             Ai   : System.Address
                            ) return Integer
      with
        Import,
        Convention => C,
        External_Name => "libc_getaddrinfo";

    function Lc_Socket (
                        Ai : System.Address
                       ) return Integer
      with
        Import,
        Convention => C,
        External_Name => "libc_socket";

    function Lc_Send (
                      S    : Integer;
                      Data : System.Address;
                      Size : Integer;
                      Ai   : System.Address
                     ) return Long_Integer
      with
        Import,
        Convention => C,
        External_Name => "libc_send";

    function Lc_Recv (
                      S       : Integer;
                      Data    : System.Address;
                      Size    : Integer;
                      Ai      : System.Address;
                      Timeout : Long_Integer
                     ) return Long_Integer
      with
        Import,
        Convention => C,
        External_Name => "libc_recv";

end Libc_Import;
