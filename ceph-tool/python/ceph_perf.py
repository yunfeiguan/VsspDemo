from ctypes import *
import os
import json
import commands
import time

msvcrt = CDLL("libc.so.6")
var = 1
while var == 1:
    status,output = commands.getstatusoutput('ceph status -f json --cluster xtao  --debug-monc=0 --debug-client=0 --debug-rados=0 --debug-objecter=0')

    json_format = json.loads(output);

    pgmap = json_format['pgmap']

    if (pgmap.has_key('write_op_per_sec')):
        write_op=pgmap['write_op_per_sec']
    else:
        write_op=0

    if (pgmap.has_key('write_bytes_sec')):
        write_bw=pgmap['write_bytes_sec']
    else:
        write_bw=0

    if (pgmap.has_key('read_op_per_sec')):
        read_op=pgmap['read_op_per_sec']
    else:
        read_op=0

    if (pgmap.has_key('read_bytes_sec')):
        read_bw=pgmap['read_bytes_sec']
    else:
        read_bw=0

    out_str = "write op:%-6d write_bw:%5d M/s read_op:%6d read_bw:%5d M/s" %(write_op, write_bw/1024/1024, read_op, read_bw/1024/1024)
    print out_str 
    #msvcrt.printf('%s,%-6d,%s,%-11d,%s,%-6d,%s,%-11d','write op:',write_op,'write dw:',write_bw,'read_op:',read_op,'read_bw:',read_bw)
    time.sleep(1)

#read_bw=json_format['pgmap']['num_pgs']
#import pdb;pdb.set_trace()
#print output
