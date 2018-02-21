with System;

package libc_import
is

    type Unsigned_32 is mod 2**32;

    function lc_getaddrinfo(Addr : System.Address; Ai : System.Address) return Integer
    with
        Import,
        Convention => C,
        External_Name => "libc_getaddrinfo";

    function lc_socket(Ai : System.Address) return Integer
    with
        Import,
        Convention => C,
        External_Name => "libc_socket";

    function lc_send(S : Integer; Data : System.Address; Size : Integer; Ai : System.Address) return Long_Integer
    with
        Import,
        Convention => C,
        External_Name => "libc_send";

    function lc_recv(S : Integer; Data : System.Address; Size : Integer; Ai : System.Address; Timeout : Long_Integer) return Long_Integer
    with
        Import,
        Convention => C,
        External_Name => "libc_recv";

end libc_import;
