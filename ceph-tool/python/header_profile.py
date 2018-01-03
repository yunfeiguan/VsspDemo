import os
import json
import time
import commands
import sys,getopt
from ctypes import *
from datetime import datetime

#profile cycle 
cycle=2
debug=0

opts, args = getopt.getopt(sys.argv[1:], "hdt:o:")

remain_log = 0
release_pos = 0
last_release_pos = 0
delta_release_pos = 0

old_time=datetime.now()
collect_num=0
output_file=" "

for op, value in opts:
    if op == "-t":
        cycle=value
    elif op == "-o":
        #import sys
        #origin = sys.stdout
        output_file = value
        #f = open(output_file, 'a+')
        #sys.stdout = f 
    elif op == "-d":
        debug=1
    elif op == "-h":
        print "Usage:"
        print "    python %s -t time_cycle [-o output_file][-h][-d]" %(sys.argv[0])
        sys.exit()
var = 1
while var == 1:
    status,output = commands.getstatusoutput('cephfs-journal-tool header get --cluster xtao')
    json_result = json.loads(output);
    
    if (json_result.has_key('write_pos')):
        write_pos=json_result['write_pos']
        if (json_result.has_key('ad_release_pos')):
            release_pos=json_result['ad_release_pos']
        
        remain_log=write_pos-release_pos
        delta_ad_pos=release_pos - last_release_pos
        last_release_pos = release_pos
    else:
        try:
            os._exit(0)
        except:
            print 'die.'

    time.sleep(float(cycle))
    new_time=datetime.now()
    delta_time=(new_time-old_time).seconds
    old_time=new_time

    if debug:
        out_str = "remain log: %dM release_pos: %-6d release_speed :%d/s time: %d"\
            %(remain_log/1024/1024, release_pos, delta_ad_pos/delta_time, delta_time) 
    else:
        out_str = "remain log: %dM release_speed: %d/s" %(remain_log/1024/1024, delta_ad_pos/delta_time)

    #import pdb;pdb.set_trace()
    if (collect_num == 0):
        collect_num += 1
        continue

    if (output_file != " "):
        commands.getstatusoutput('echo {0} {1} remain_log: {2}M speed: {3} | tee -a {4}'.format\
            (collect_num, datetime.now(), remain_log/1024/1024, delta_ad_pos/delta_time, output_file))
        #print "%d, %dM, %d" %(collect_num, remain_log/1024/1024, delta_ad_pos/delta_time)
    print out_str 

    collect_num += 1

f.close()
