with System;

package body Terminal.Session is

   ----------
   -- Read --
   ----------

   function Read
     (Size : Integer)
      return Integer
   is
   begin
      Debug("Read");
      return Size;
   end Read;

   -----------
   -- Write --
   -----------

   function Write
     (Size : Integer)
      return Integer
   is
   begin
      Debug("Write");
      return Size;
   end Write;

   procedure Debug (
                    Msg : String
                   )
   is
      procedure Dbg (
                     Cstr : System.Address
                    )
        with
          Import,
          Convention => C,
          External_Name => "debug";
      C_Msg : String := Msg & Character'Val (0);
   begin
      Dbg (C_Msg'Address);
   end Debug;

end Terminal.Session;
