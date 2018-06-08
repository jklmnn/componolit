with Terminal.Connection;

package Terminal.Session is

   type Attached_Ram_Dataspace is limited record
      null;
   end record
     with Size => 8 * 48;

   type Component is limited record
      Io_Buffer : Attached_Ram_Dataspace;
      Terminal  : Connection.Connection;
   end record
     with
       Size => 3200,
       Import,
       Convention => CPP;

   function Read (
                  Size : Integer
                 ) return Integer
     with
       Export,
       Convention => CPP,
       External_Name => "_ZN11Http_Filter9Component5_readEm";

   function Write (
                   Size : Integer
                  ) return Integer
     with
       Export,
       Convention => CPP,
       External_Name => "_ZN11Http_Filter9Component6_writeEm";

private

   procedure Debug (
                    Msg : String
                   );

end Terminal.Session;

