with Fw_Types;
use all type Fw_Types.U08;
use all type Fw_Types.U16;
use all type Fw_Types.U32;
use all type Fw_Types.U64;

package Dissector
with
SPARK_Mode
is

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
                   ) return Boolean
      with
        Depends => (Valid'Result => (Header, Payload, Dir)),
        Post => (if Payload'Length <= 1500 and Payload'Length >= 46 and
                   Header.Source.NIC_2 /= 0
                   then Valid'Result else Valid'Result = False);

    function Valid (
                    Header   : Fw_Types.Sl3p;
                    Payload  : Fw_Types.Buffer;
                    Sequence : Fw_Types.U64
                   ) return Boolean
      with
        Depends => (Valid'Result => (Header, Payload, Sequence)),
        Pre => Payload'Length <= 1500,
        Post => (if Header.Sequence_number > Sequence and
                   (if Header.Length <= 34 then Payload'Length = 34 else
                          Payload'Length = Header.Length) and
                         Header.Length <= 1488 and
                           Header.Sequence_number > 0
                             then Valid'Result else Valid'Result = False);

    function Valid (
                    Header  : Fw_Types.RIL;
                    Payload : Fw_Types.Buffer
                   ) return Boolean
      with
        Depends => (Valid'Result => (Header, Payload)),
        Pre => Payload'Length > 0 and Payload'Length < Fw_Types.U32'Last,
      Post => (if Header.Length = Payload'Length
                 then Valid'Result else Valid'Result = False);

private

    generic
        type UXX is mod <>;
    function UXX_Be (Buffer : Fw_Types.Buffer)
                     return UXX
      with
        Depends => (UXX_Be'Result => Buffer),
      Pre => UXX'Size rem 8 = 0 and then Buffer'Length = UXX'Size / 8;

end Dissector;
