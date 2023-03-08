#!/usr/bin/env python


from datetime import datetime
import os
import sys
import getopt
import commands
from IPy import IP
import ConfigParser
import re
import json
import logging


logging.basicConfig(level=logging.INFO,
                    format = '%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
                    datafmt = '%a, %d %b %Y %H:%M:%S',
                    filename = '/var/log/xt/xtlock.log',
                    filemode = 'a')


logger = logging.getLogger()


def exec_cmd(cmdline):
    status, output = commands.getstatusoutput(cmdline)
    logger.info(cmdline)
    logger.info('status %d, output %s' % (status, output))
    if status:
        logger.error('fail: %s' % cmdline)
        raise Exception(output.strip('\n'))
        sys.exit(1)
    return status, output


def exec_cmd_noerror(cmdline):
    status, output = commands.getstatusoutput(cmdline)
    logger.info(cmdline)
    logger.info('status %d, output %s' % (status, output))
    return status, output


def main(argv=None):


    inode = sys.argv[1]
    inode += '.00000000'

    #another way to implement
    rados_cmd = 'rados -p annafs_metadata getxattr %s  parent --cluster xtao > /tmp/1.txt' % inode
    status, output = exec_cmd(rados_cmd)
    ceph_dencoder = 'ceph-dencoder import /tmp/1.txt type inode_backtrace_t decode dump_json'
    status, output = exec_cmd(ceph_dencoder)
    jout = json.loads(output)
    ancestors = jout['ancestors']
    str = ''
    for info in ancestors[::-1]:
        str += ('/' + info['dname'])
    basedir = '/mnt/vol1'
    fullpath = basedir + str
    print 'will tail %s' % fullpath
    #tailcmd = 'tail -n 1 %s' % fullpath
    #status,output = exec_cmd(tailcmd)
    print output
    sys.exit(0)

if __name__ == "__main__":
    sys.exit(main())
