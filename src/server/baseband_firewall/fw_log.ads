with Fw_Types;
use all type Fw_Types.U08;

package Fw_Log
is
    subtype Arrow is String (1 .. 2);

    function Directed_Arrow (Dir : Fw_Types.Direction) return Arrow;
end Fw_Log;
