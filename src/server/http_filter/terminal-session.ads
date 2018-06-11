with Terminal.Connection;
with Base.Attached_Ram_Dataspace;
with System;

package Terminal.Session is

   type Component is tagged limited record
      Io_Buffer : aliased Base.Attached_Ram_Dataspace.Attached_Ram_Dataspace;
      Terminal  : aliased Connection.Connection;
   end record
     with
       Import,
       Convention => CPP;

   for Component use record
      Io_Buffer at 144 range 0 .. 319;
      Terminal at 192 range 0 .. 2815;
   end record;

   function New_Component (
                           Env : System.Address;
                           Ram_Session : System.Address;
                           Region_Map  : System.Address;
                           Size        : Long_Integer
                          ) return Component;
   pragma CPP_Constructor (New_Component, "_ZN11Http_Filter9ComponentC1ERN6Genode3EnvERNS1_10Pd_sessionERNS1_10Region_mapEm");

   function Read (
                  This : access Component;
                  Size : Integer
                 ) return Integer
     with
       Export,
       Convention => CPP,
       External_Name => "_ZN11Http_Filter9Component5_readEm";

   function Write (
                   This : access Component;
                   Size : Integer
                  ) return Integer
     with
       Export,
       Convention => CPP,
       External_Name => "_ZN11Http_Filter9Component6_writeEm";

   function Cpp_Write (
                       This : access Component;
                       Size : Integer;
                       Buffer : System.Address
                      ) return Integer
     with
       Import,
       Convention => CPP,
       External_Name => "_ZN11Http_Filter9Component9cpp_writeEmPv";

   function Cpp_Read (
                      This : access Component;
                      Size : Integer;
                      Buffer : System.Address
                     ) return Integer
     with
       Import,
       Convention => CPP,
       External_Name => "_ZN11Http_Filter9Component8cpp_readEmPv";

private

   generic
      type T is private;
   procedure Debug (
                    Pointer : T;
                    Msg     : String
                   );

end Terminal.Session;

