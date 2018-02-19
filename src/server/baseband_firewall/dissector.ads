with Fw_Types;
use all type Fw_Types.U08;
use all type Fw_Types.U16;
use all type Fw_Types.U32;
use all type Fw_Types.U64;

package Dissector
with
SPARK_Mode
is

    function Eth_Be (buffer : Fw_Types.Buffer)
                     return Fw_Types.Eth
      with
        Depends => (Eth_Be'Result => buffer),
      Pre => buffer'Length >= Fw_Types.Eth'Size / 8;

    function Sl3p_Be (buffer : Fw_Types.Buffer)
                      return Fw_Types.Sl3p
      with
        Depends => (Sl3p_Be'Result => buffer),
      Pre => buffer'Length >= Fw_Types.Sl3p'Size / 8;

    function Ril_Be (buffer : Fw_Types.Buffer)
                     return Fw_Types.RIL
      with
        Depends => (Ril_Be'Result => buffer),
      Pre => buffer'Length >= Fw_Types.RIL'Size / 8;

    function Valid (header : Fw_Types.Eth; payload : Fw_Types.Buffer)
                    return Boolean
      with
        Depends => (Valid'Result => (header, payload)),
        Post => (if payload'Length <= 1500 and payload'Length >= 46
                   then Valid'Result else Valid'Result = False);

    function Valid (header : Fw_Types.Sl3p; payload : Fw_Types.Buffer; sequence : Fw_Types.U64)
                    return Boolean
      with
        Depends => (Valid'Result => (header, payload, sequence)),
        Pre => payload'Length <= 1500,
        Post => (if header.Sequence_number > sequence and
                   (if header.Length <= 34 then payload'Length = 34 else
                          payload'Length = header.Length) and
                         header.Length <= 1488 and
                           header.Sequence_number > 0
                             then Valid'Result else Valid'Result = False);

    function Valid (header : Fw_Types.RIL; payload : Fw_Types.Buffer)
                    return Boolean
      with
        Depends => (Valid'Result => (header, payload)),
        Pre => payload'Length > 0 and payload'Length < Fw_Types.U32'Last,
      Post => (if header.Length = payload'Length
                 then Valid'Result else Valid'Result = False);

private

    generic
        type UXX is mod <>;
    function UXX_Be (buffer : Fw_Types.Buffer)
                     return UXX
      with
        Depends => (UXX_Be'Result => buffer),
      Pre => UXX'Size rem 8 = 0 and then buffer'Length = UXX'Size / 8;

end Dissector;
