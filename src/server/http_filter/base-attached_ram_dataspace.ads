with System;

package Base.Attached_Ram_Dataspace is

   type Attached_Ram_Dataspace is limited record
      Size          : Integer;
      Size2         : Integer;
      Ram_Allocator : System.Address;
      Region_Map    : System.Address;
      Dataspace     : System.Address;
      Local_Address : System.Address;
   end record
     with
       Import,
       Convention => CPP;

   function New_Attached_Ram_Dataspace
     (Ram    : System.Address;
      Rm     : System.Address;
      Size   : Long_Integer;
      Cached : Long_Integer) return Attached_Ram_Dataspace;  -- /home/jk/workspace/componolit/http_filter/repos/base/include/base/attached_ram_dataspace.h:102
   pragma CPP_Constructor (New_Attached_Ram_Dataspace, "_ZN6Genode22Attached_ram_dataspaceC1ERNS_13Ram_allocatorERNS_10Region_mapEmNS_15Cache_attributeE");

end Base.Attached_Ram_Dataspace;
