package Genode_Log
with
    Abstract_State => State,
    Initializes    => State
is

    procedure Log (Msg : String)
    with
        Global => (In_Out => State);

    procedure Warn (Msg : String)
    with
        Global => (In_Out => State);

    procedure Error (Msg : String)
    with
        Global => (In_Out => State);

    procedure Int (Num : Integer)
    with
        Global => (In_Out => State);

end Genode_Log;
