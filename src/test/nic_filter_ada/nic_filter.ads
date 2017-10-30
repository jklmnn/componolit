package Nic_filter is

    procedure log(Num: Integer) with 
        Import,
        Convention => C,
        External_name => "_ZN15Nic_filter_test6Filter11hello_worldEi";
    procedure test(Num: Integer);

end Nic_filter;
