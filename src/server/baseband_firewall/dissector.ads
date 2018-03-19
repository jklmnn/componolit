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
            Status      : Result;
        end record;

    Eth_Offset : constant Fw_Types.U32_Index := 14;

    subtype Sl3p_Length is Fw_Types.U32 range 0 .. 1488;

    type Sl3p is
        record
            Sequence_Number : Fw_Types.U64;
            Length          : Sl3p_Length;
            Status          : Result;
        end record;

    Sl3p_Offset : constant Fw_Types.U32_Index := 12;

    type RIL is record
        Length      : Fw_Types.U32;
        ID          : Fw_Types.U32;
        Token_Event : Fw_Types.U32;
        Status      : Result;
    end record;

    RIL_Offset : constant Fw_Types.U32_Index := 12;

    function Eth_Be (
                     Buffer : Fw_Types.Buffer;
                     Dir    : Fw_Types.Direction
                    ) return Eth
      with
        Depends => (Eth_Be'Result => (Buffer, Dir)),
        Pre => Buffer'Length >= Eth_Offset,
        Post => (if Eth_Be'Result.Status = Checked then
                   Buffer'Length <= 1514 and
                     Buffer'Length >= 60 and
                       Eth_Be'Result.Source.NIC_2 /= 0 and
                         Dir /= Fw_Types.Unknown);

    procedure Eth_Be (
                      Header : Eth;
                      Buffer : out Fw_Types.Buffer
                    )
      with
        Depends => (Buffer =>+ Header),
      Pre => Buffer'Length = Eth_Offset and
      Header.Status = Checked;

    function Sl3p_Be (
                      Buffer : Fw_Types.Buffer;
                      Sequence : Fw_Types.U64
                     ) return Sl3p
      with
        Depends => (Sl3p_Be'Result => (Buffer, Sequence)),
      Pre => Buffer'Length >= Sl3p_Offset and Buffer'Length <= 1500,
      Post => (if Sl3p_Be'Result.Status = Checked then
                 Sl3p_Be'Result.Sequence_Number > Sequence and
                   (if Sl3p_Be'Result.Length <= 34 then Buffer'Length = 34 + Sl3p_Offset else
                        Buffer'Length = Sl3p_Be'Result.Length + Sl3p_Offset) and
                     Sl3p_Be'Result.Length <= 1488 and
                       Sl3p_Be'Result.Sequence_Number > 0 and
                         Buffer'Length >= Sl3p_Be'Result.Length);

    procedure Sl3p_Be (
                      Header : Sl3p;
                      Buffer : out Fw_Types.Buffer
                     )
      with
        Depends => (Buffer =>+ Header),
      Pre => Buffer'Length = Sl3p_Offset and Header.Status = Checked;

    function Ril_Be (
                     Buffer : Fw_Types.Buffer
                    ) return RIL
      with
        Depends => (Ril_Be'Result => Buffer),
      Pre => Buffer'Length >= RIL_Offset,
      Post => (if Ril_Be'Result.Status = Checked then
                 Ril_Be'Result.Length <= Buffer'Length and Ril_Be'Result.Length > 0);

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
