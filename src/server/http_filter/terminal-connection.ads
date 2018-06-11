with System;
with Terminal.Client;

package Terminal.Connection is

   type Connection is limited new Terminal.Client.Session_Client with record
      null;
   end record
     with
       Size => 2816,
       Import,
       Convention => CPP;

   function New_Connection (Env : System.Address; Label : System.Address) return Connection;  -- /home/jk/workspace/componolit/http_filter/repos/os/include/terminal_session/connection.h:50
   pragma CPP_Constructor (New_Connection, "_ZN8Terminal10ConnectionC1ERN6Genode3EnvEPKc");

end Terminal.Connection;
