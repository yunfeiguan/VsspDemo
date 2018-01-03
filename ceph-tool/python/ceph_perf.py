from ctypes import *
import os
import json
import commands
import time
import sys,getopt
from datetime import datetime

#profile cycle 
cycle=2

debug=0
output_file=" "

opts, args = getopt.getopt(sys.argv[1:], "hdt:o:")

for op, value in opts:
    if op == "-t":
        cycle=value
    elif op == "-o":
        output_file = value
    elif op == "-d":
        debug=1
    elif op == "-h":
        print "Usage:"
        print "    python %s -t time_cycle [-o output_file][-h][-d]" %(sys.argv[0])
        sys.exit()

collect_num=0
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
    
    if (output_file != " "):
        commands.getstatusoutput('echo {0} {1} {2} | tee -a {3}'.format(collect_num, datetime.now(), out_str, output_file))
    if (collect_num == 0):
        collect_num += 1
        continue
    time.sleep(1)
    collect_num += 1
    
#read_bw=json_format['pgmap']['num_pgs']
#import pdb;pdb.set_trace()
#print output
