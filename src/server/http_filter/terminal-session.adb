
package body Terminal.Session is

   procedure Debug (
                    Pointer : T;
                    Msg     : String
                   )
   is
      procedure Dbg (
                     Ptr  : T;
                     Cstr : System.Address
                    )
        with
          Import,
          Convention => C,
          External_Name => "debug";
      C_Msg : String := Msg & Character'Val (0);
   begin
      Dbg (Pointer, C_Msg'Address);
   end Debug;

   procedure Debug_Ptr is new Debug (System.Address);
   procedure Debug_Int is new Debug (Long_Integer);

   ----------
   -- Read --
   ----------

   function Read (
                  This : access Component;
                  Size : Integer
                 ) return Integer
   is
      pragma Unreferenced (This);
   begin
      Debug_Ptr(System.Null_Address, "Read");
      return Size;
   end Read;

   -----------
   -- Write --
   -----------

   function Write (
                   This : access Component;
                   Size : Integer
                  ) return Integer
   is
      Buffer : String (1 .. This.Io_Buffer.Size)
        with
          Address => This.Io_Buffer.Local_Address;
   begin
      Debug_Ptr (This.Io_Buffer.Local_Address, "Write");
      Debug_Int (Long_Integer (This.Io_Buffer.Size), Buffer);
      return This.Terminal.Write(This.Io_Buffer.Local_Address, Size);
   end Write;

end Terminal.Session;
