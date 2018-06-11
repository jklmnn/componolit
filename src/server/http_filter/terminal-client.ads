with System;

package Terminal.Client is

   type Session_Client is tagged limited record
      null;
   end record
     with
       Size => 640,
       Import,
       Convention => CPP;

   function New_Session_Client (Local_Rm : System.Address; Cap : System.Address) return Session_Client;  -- /home/jk/workspace/componolit/http_filter/repos/os/include/terminal_session/client.h:43
   pragma CPP_Constructor (New_Session_Client, "_ZN8Terminal14Session_clientC1ERN6Genode10Region_mapENS1_10CapabilityINS_7SessionEEE");

   function Read
     (This     : access Session_Client;
      Buf      : System.Address;
      Buf_Size : Integer) return Integer;  -- /home/jk/workspace/componolit/http_filter/repos/os/include/terminal_session/client.h:59
   pragma Import (CPP, Read, "_ZN8Terminal14Session_client4readEPvm");

   function Write
     (This      : access Session_Client;
      Buf       : System.Address;
      Num_Bytes : Integer) return Integer;  -- /home/jk/workspace/componolit/http_filter/repos/os/include/terminal_session/client.h:73
   pragma Import (CPP, Write, "_ZN8Terminal14Session_client5writeEPKvm");

end Terminal.Client;
