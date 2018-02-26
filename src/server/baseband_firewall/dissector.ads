with Fw_Types;
use all type Fw_Types.U08;
use all type Fw_Types.U16;
use all type Fw_Types.U32;
use all type Fw_Types.U64;

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

    function Eth_Be (
                     Buffer : Fw_Types.Buffer
                    ) return Fw_Types.Eth
      with
        Depends => (Eth_Be'Result => Buffer),
      Pre => Buffer'Length >= 14;

    function Sl3p_Be (
                      Buffer : Fw_Types.Buffer
                     ) return Fw_Types.Sl3p
      with
        Depends => (Sl3p_Be'Result => Buffer),
      Pre => Buffer'Length >= Fw_Types.Sl3p'Size / 8;

    function Ril_Be (
                     Buffer : Fw_Types.Buffer
                    ) return Fw_Types.RIL
      with
        Depends => (Ril_Be'Result => Buffer),
      Pre => Buffer'Length >= Fw_Types.RIL'Size / 8;

    function Valid (
                    Header  : Fw_Types.Eth;
                    Payload : Fw_Types.Buffer;
                    Dir     : Fw_Types.Direction
                   ) return Result
      with
        Depends => (Valid'Result => (Header, Payload, Dir)),
        Post => (if Payload'Length <= 1500 and Payload'Length >= 46 and
                   Header.Source.NIC_2 /= 0
                   then Valid'Result = Checked);

    function Valid (
                    Header   : Fw_Types.Sl3p;
                    Payload  : Fw_Types.Buffer;
                    Sequence : Fw_Types.U64
                   ) return Result
      with
        Depends => (Valid'Result => (Header, Payload, Sequence)),
        Pre => Payload'Length <= 1500,
        Post => (if Header.Sequence_number > Sequence and
                   (if Header.Length <= 34 then Payload'Length = 34 else
                          Payload'Length = Header.Length) and
                         Header.Length <= 1488 and
                           Header.Sequence_number > 0
                             then Valid'Result = Checked);

    function Valid (
                    Header  : Fw_Types.RIL;
                    Payload : Fw_Types.Buffer
                   ) return Result
      with
        Depends => (Valid'Result => (Header, Payload)),
        Pre => Payload'Length > 0 and Payload'Length < Fw_Types.U32'Last,
      Post => (if Header.Length = Payload'Length
                 then Valid'Result = Checked);

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
    function UXX_Be (Buffer : Fw_Types.Buffer)
                     return UXX
      with
        Depends => (UXX_Be'Result => Buffer),
      Pre => UXX'Size rem 8 = 0 and then Buffer'Length = UXX'Size / 8;

end Dissector;
