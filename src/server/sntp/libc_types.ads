with System;

package libc_types is

    type Addrinfo is new System.Address;
    type Socket is new Integer;

    Null_Address : constant Addrinfo := Addrinfo(System.Null_Address);

end libc_types;
