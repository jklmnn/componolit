#!/usr/bin/python3

import re

def to_struct (value):
    return "Fw_Types.Buffer'(16#%2.2x#, 16#%2.2x#, 16#%2.2x#, 16#%2.2x#)" % \
        ((value & 0x000000ff) >>  0,
         (value & 0x0000ff00) >>  8,
         (value & 0x00ff0000) >> 16,
         (value & 0xff000000) >> 24)


with open ("ril.h", 'r') as r:
    for line in r:
        match = re.match ('#define\s+RIL_(REQUEST|RESPONSE|UNSOL)_([^ ]+)\s+(.*)', line)
        if match:
            print ('elsif Msg = %s then\n    Fw_Log.Log (Arrow & " %s");' % (to_struct (int(match.group(3))), match.group(1) + "_" + match.group(2)))
