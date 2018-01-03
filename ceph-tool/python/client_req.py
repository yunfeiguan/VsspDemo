import os
import json
import time
import commands
import sys,getopt
from ctypes import *
from datetime import datetime


#msvcrt = CDLL("libc.so.6")

#profile cycle 
cycle=2
debug=0

opts, args = getopt.getopt(sys.argv[1:], "hdt:o:")

client_reqs = 0
last_client_reqs = 0
delta_client_reqs = 0
old_time=datetime.now()
collect_num=0
output_file=" "

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
var = 1
while var == 1:
    status,output = commands.getstatusoutput('ceph daemon mds.xt2 perf dump mds_server --cluster xtao')
    json_result = json.loads(output);
    
    mds_server = json_result['mds_server']
    if (mds_server.has_key('handle_client_request')):
        client_reqs=mds_server['handle_client_request']
        delta_client_reqs = client_reqs - last_client_reqs
        last_client_reqs = client_reqs
    else:
        client_reqs=0

    time.sleep(float(cycle))
    new_time=datetime.now()
    delta_time=(new_time-old_time).seconds
    old_time=new_time

    if debug:
        out_str = "client_seqs: %-6d client_seqs/s :%-6d time: %d"\
            %(client_reqs, delta_client_reqs/delta_time, delta_time) 
    else:
        out_str = "client_seqs/s: %-6d" %(delta_client_reqs/delta_time)

    #import pdb;pdb.set_trace()
    if (collect_num == 0):
        collect_num += 1
        continue

    if (output_file != " "):
        commands.getstatusoutput('echo {0} {1} clinet_reqs {2}/s | tee -a {3}'.format\
            (collect_num, datetime.now(), delta_client_reqs/delta_time, output_file))
    print out_str 

    collect_num += 1

f.close()
