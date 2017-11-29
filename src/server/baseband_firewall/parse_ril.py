#!/usr/bin/python3

import re

def to_struct (value):
    return "Buffer'((%s,%s),(%s,%s),(%s,%s),(%s,%s))" % \
        ((value & 0xf0000000) >> 28,
         (value & 0x0f000000) >> 24,
         (value & 0x00f00000) >> 20,
         (value & 0x000f0000) >> 16,
         (value & 0x0000f000) >> 12,
         (value & 0x00000f00) >>  8,
         (value & 0x000000f0) >>  4,
         (value & 0x0000000f) >>  0)


with open ("ril.h", 'r') as r:
    for line in r:
        match = re.match ('#define\s+RIL_(REQUEST|RESPONSE|UNSOL)_([^ ]+)\s+(.*)', line)
        if match:
            print ('elsif source.ril_packet.id = %s then fw_log.log (arrow & " %s");' % (to_struct (int(match.group(3))), match.group(1) + "_" + match.group(2)))
