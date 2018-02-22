with System;
with Libc_Import;

package body Libc
with
SPARK_Mode => On
is

    pragma Warnings (Off, "pragma Restrictions (No_Exception_Propagation) in effect");

    function Getaddrinfo (
                          Address : String;
                          Ai      : Libc_Types.Addrinfo
                         ) return Integer
      with
        SPARK_Mode => Off
    is
        C_Address : String := Address & Character'Val (0);
    begin
        return Libc_Import.Lc_Getaddrinfo (C_Address'Address,
                                           System.Address (Ai));
    end Getaddrinfo;

    function Getsocket (
                        Ai : Libc_Types.Addrinfo
                       ) return Libc_Types.Socket
      with
        SPARK_Mode => Off
    is
    begin
        return Libc_Types.Socket (Libc_Import.Lc_Socket (System.Address (Ai)));
    end Getsocket;

    procedure Send (
                    Sock : Libc_Types.Socket;
                    Msg  : Sntp_Types.Message;
                    Ai   : Libc_Types.Addrinfo;
                    Sent : out Long_Integer
                   )
      with
        SPARK_Mode => Off
    is
    begin
        Sent := Libc_Import.Lc_Send (Integer (Sock),
                                     Msg'Address, Sntp_Types.Message'Size / 8,
                                     System.Address (Ai));
    end Send;

    procedure Recv (
                    Sock     : Libc_Types.Socket;
                    Msg      : out Sntp_Types.Message;
                    Ai       : Libc_Types.Addrinfo;
                    Timeout  : Long_Integer;
                    Received : out Long_Integer
                   )
      with SPARK_Mode => Off
    is
    begin
        Received := Libc_Import.Lc_Recv (Integer (Sock),
                                         Msg'Address, Msg'Size / 8,
                                         System.Address (Ai), Timeout);
    end Recv;

end Libc;
