with JWX.Stream_Auth;

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

   Key_Data : String := "{ ""kty"": ""oct"", ""k"": ""dmdjMzU1ejIxOVNHTS1LZllfN3ZLNXJ3Mk1qTnVXbUhMRUZnRlI5ZWFLYTdKTXZESld2TmJZbDA4RzBCeFVHZQ"" }";
   Audience : constant String := "4cCy0QeXkvjtHejID0lKzVioMfTmuXaM";
   Issuer   : constant String := "https://cmpnlt-demo.eu.auth0.com/";

   ----------
   -- Read --
   ----------

   function Read (
                  This : access Component;
                  Size : Integer
                 ) return Integer
   is
      Buffer : String (1 .. This.Io_Buffer.Size)
        with
          Address => This.Io_Buffer.Local_Address;

      Error : constant String :=
            "HTTP/1.1 401 Unauthorized"
            & ASCII.CR & ASCII.LF
            & "Connection: Keep-Alive"
            & ASCII.CR & ASCII.LF
            & "Content-Length: 70"
            & ASCII.CR & ASCII.LF
            & ASCII.CR & ASCII.LF
            & "<HTML><BODY><H1>Unauthorized request. Please login.</H1></BODY></HTML>"
            & Character'Val (0);

   begin
      if not This.Authenticated
      then
         Buffer := (others => ' ');
         Buffer (1 .. Error'Length) := Error;
         This.Available := False;
         return Error'Length;
      end if;

      Debug_Int (1, "Read: Authenticated, sending message");
      Debug_Int (Long_Integer (Size), Buffer);
      --  This.Available := True;
      return This.Cpp_Read (Size, This.Io_Buffer.Local_Address);
   end Read;

   -----------
   -- Write --
   -----------

   function Write (
                   This : access Component;
                   Size : Integer
                  ) return Integer
   is
      package SA is new JWX.Stream_Auth (Key_Data, Audience, Issuer);
      use SA;

      Buffer : String (1 .. This.Io_Buffer.Size)
        with
          Address => This.Io_Buffer.Local_Address;

      Result        : Auth_Result_Type;
      Bytes_Written : Integer;

   begin
      Debug_Ptr (This.Io_Buffer.Local_Address, "Write");
      This.Authenticated := False;

      -- FIXME: Timestamp
      Result := Authenticated (Buffer, 20000000);
      if Result /= Auth_OK
      then
         Debug_Int (0, "Write: not authenticated, sending signal");
         -- Send signal
         This.Available := True;
         This.Cpp_Transmit;
         return Size;
      else
         This.Authenticated := True;
      end if;

      Debug_Int (Auth_Result_Type'Pos (Result), "Write: authenticated, sending message");
      -- This.Available := False;
      Debug_Int (Long_Integer (Size), Buffer);
      return This.Cpp_Write (Size, This.Io_Buffer.Local_Address);
   end Write;

end Terminal.Session;
