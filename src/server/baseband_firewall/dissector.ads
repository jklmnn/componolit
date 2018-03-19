with Fw_Types;
use all type Fw_Types.U08;
use all type Fw_Types.U16;
use all type Fw_Types.U32;
use all type Fw_Types.U64;
use all type Fw_Types.Direction;

package Dissector
with
SPARK_Mode
is

    type Result is (
                    Checked,
                    Unchecked,
                    Payload_To_Short,
                    Payload_To_Long,
                    Invalid_Sequence_Number,
                    Invalid_Size,
                    Invalid_Direction,
                    Forbidden_Address
                   );

    subtype Result_String is String (1 .. 7);

    subtype Sl3p_Buffer is Fw_Types.Buffer (0 .. 11);
    subtype Eth_Buffer is Fw_Types.Buffer (0 .. 13);

    type Mac is
        record
            OUI_0 : Fw_Types.U08;
            OUI_1 : Fw_Types.U08;
            OUI_2 : Fw_Types.U08;
            NIC_0 : Fw_Types.U08;
            NIC_1 : Fw_Types.U08;
            NIC_2 : Fw_Types.U08;
        end record with
      Size => 48;

    for Mac use
        record
            OUI_0 at 0 range 0 .. 7;
            OUI_1 at 1 range 0 .. 7;
            OUI_2 at 2 range 0 .. 7;
            NIC_0 at 3 range 0 .. 7;
            NIC_1 at 4 range 0 .. 7;
            NIC_2 at 5 range 0 .. 7;
        end record;

    type Eth is
        record
            Destination : Mac;
            Source      : Mac;
            Ethtype     : Fw_Types.U16;
        end record;

    Eth_Offset : constant Fw_Types.U32_Index := 14;

    subtype Sl3p_Length is Fw_Types.U32 range 0 .. 1488;

    type Sl3p is
        record
            Sequence_Number : Fw_Types.U64;
            Length          : Sl3p_Length;
            --  Status          : Dissector.Result;
        end record;

    Sl3p_Offset : constant Fw_Types.U32_Index := 12;

    type RIL is record
        Length      : Fw_Types.U32;
        ID          : Fw_Types.U32;
        Token_Event : Fw_Types.U32;
    end record;

    RIL_Offset : constant Fw_Types.U32_Index := 12;

    function Eth_Be (
                     Buffer : Fw_Types.Buffer
                    ) return Eth
      with
        Depends => (Eth_Be'Result => Buffer),
      Pre => Buffer'Length >= Eth_Offset;

    procedure Eth_Be (
                      Header : Eth;
                      Buffer : out Fw_Types.Buffer
                    )
      with
        Depends => (Buffer =>+ Header),
      Pre => Buffer'Length = Eth_Offset;

    function Sl3p_Be (
                      Buffer : Fw_Types.Buffer
                     ) return Sl3p
      with
        Depends => (Sl3p_Be'Result => Buffer),
      Pre => Buffer'Length >= Sl3p_Offset;

    procedure Sl3p_Be (
                      Header : Sl3p;
                      Buffer : out Fw_Types.Buffer
                     )
      with
        Depends => (Buffer =>+ Header),
      Pre => Buffer'Length = Sl3p_Offset;

    function Ril_Be (
                     Buffer : Fw_Types.Buffer
                    ) return RIL
      with
        Depends => (Ril_Be'Result => Buffer),
      Pre => Buffer'Length >= RIL_Offset;

    function Valid (
                    Header  : Eth;
                    Payload : Fw_Types.Buffer;
                    Dir     : Fw_Types.Direction
                   ) return Result
      with
        Depends => (Valid'Result => (Header, Payload, Dir)),
        Post => (if Valid'Result = Checked then
                   Payload'Length <= 1500 and
                     Payload'Length >= 46 and
                       Header.Source.NIC_2 /= 0 and
                Dir /= Fw_Types.Unknown);

    function Valid (
                    Header   : Sl3p;
                    Payload  : Fw_Types.Buffer;
                    Sequence : Fw_Types.U64
                   ) return Result
      with
        Depends => (Valid'Result => (Header, Payload, Sequence)),
        Pre => Payload'Length <= 1500,
        Post => (if Valid'Result = Checked then
                   Header.Sequence_Number > Sequence and
                     (if Header.Length <= 34 then Payload'Length = 34 else
                            Payload'Length = Header.Length) and
                         Header.Length <= 1488 and
                           Header.Sequence_Number > 0 and
                Payload'Length >= Header.Length);

    function Valid (
                    Header  : RIL;
                    Payload : Fw_Types.Buffer
                   ) return Result
      with
        Depends => (Valid'Result => (Header, Payload)),
        Pre => Payload'Length > 0 and Payload'Length < Fw_Types.U32'Last,
      Post => (if Valid'Result = Checked then
                 Header.Length <= Payload'Length and Header.Length > 0);

    function Image (
                    R : Result
                   ) return Result_String;

private

    procedure Check_Condition (
                               Status          : in out Result;
                               Condition       : Boolean;
                               Result_On_False : Result
                              )
      with
        Depends => (Status =>+ (Condition, Result_On_False)),
        Pre => Status /= Checked,
        Contract_Cases =>
          ((Status = Unchecked and Condition = False) => Status = Result_On_False,
           (Status /= Unchecked) => Status = Status'Old,
           (Status = Unchecked and Condition) => Status = Unchecked);

    generic
        type UXX is mod <>;
    function UXX_Be (
                     Buffer : Fw_Types.Buffer
                    ) return UXX
      with
        Depends => (UXX_Be'Result => Buffer),
      Pre => UXX'Size rem 8 = 0 and then Buffer'Length = UXX'Size / 8;

    generic
        type UXX is mod <>;
    procedure Be_UXX (
                      Value  : UXX;
                      Buffer : out Fw_Types.Buffer
                     )
      with
        Depends => (Buffer =>+ Value),
      Pre => UXX'Size rem 8 = 0 and then Buffer'Length = UXX'Size / 8;

end Dissector;
