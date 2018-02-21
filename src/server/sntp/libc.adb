with System;
with libc_import;

package body libc
with
SPARK_Mode => On
is

    pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");
    
    function getaddrinfo(Address : String; Ai : libc_types.Addrinfo) return Integer
      with
        SPARK_Mode => Off
    is
        C_Address : String := Address & Character'Val(0);
    begin
        return libc_import.lc_getaddrinfo(C_Address'Address,
                                           System.Address(Ai));
    end getaddrinfo;
    
    function getsocket(Ai : libc_types.Addrinfo) return libc_types.Socket
      with
        SPARK_Mode => Off
    is
    begin
        return libc_types.Socket(libc_import.lc_socket(System.Address(Ai)));
    end getsocket;

    procedure send(Sock : libc_types.Socket; Msg : sntp_types.Message;
                   Ai : libc_types.Addrinfo; Sent : out Long_Integer)
      with
        SPARK_Mode => Off
    is
    begin
        Sent := libc_import.lc_send(Integer(Sock),
                                     Msg'Address, sntp_types.Message'Size / 8,
                                     System.Address(Ai));
    end send;

    procedure recv(Sock : libc_types.Socket; Msg : out sntp_types.Message;
                   Ai : libc_types.Addrinfo; Timeout : Long_Integer;
                   Received : out Long_Integer)
      with SPARK_Mode => Off
    is
    begin
        Received := libc_import.lc_recv(Integer(Sock),
                                         Msg'Address, Msg'Size / 8,
                                         System.Address(Ai), Timeout);
    end recv;
    
end libc;
        
