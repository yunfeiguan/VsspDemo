#!/bin/python

import sys
import commands
import os
import time
import docopt
import ConfigParser
import logging
import datetime

doc="""
CLI

usage: test_argv.py --help
       test_argv.py --run <run_type_name> --mountpoint <mountpoint> --log <test_log_file> <test_config>

Run stress testcase of ceph integration tests.

Miscellaneous arguments:
  -h, --help       Show this help message and exit

Standard arguments:
  <test_config>               test configuration file
  --run <run_type_name>       run test like vjtree,iozone,rsync,fsstress,mdtest,pjd
  --mountpoint <mountpoint>   fuse mountpoint
  --log <test_log_file>       test log file name
"""

class TestXtao:
    def __init__(self, doc, argv_test):
        self.args = docopt.docopt(doc, argv=argv_test)
        self.run = self.args['--run']
        self.mountpoint = self.args['--mountpoint']
        self.test_config_path = self.args['<test_config>']
        self.test_log = self.args['--log']
        
        self.init_log()
        
        self.init_config()

        # test case
        self.start_time = datetime.datetime.now()
        logging.info('Start test {0}...'.format(self.run))
        if self.run == 'vjtree':
            self.test_vjtree()
        elif self.run == 'iozone':
            self.test_iozone()
        elif self.run == 'rsync':
            self.test_rsync()
        elif self.run == 'fsstress':
            self.test_fsstress()
        elif self.run == 'mdtest':
            self.test_mdtest()
        elif self.run == 'pjd':
            self.test_pjd()
        elif self.run == 'fio':
            self.test_fio()
        elif self.run == 'smallfile':
            self.test_smallfile()
        else:
            logging('Your parameter is wrong')
        #end_time = datetime.datetime.now()
        #logging.info('End test {0}...'.format(self.run))
        #logging.info('perform test {0} case of time: {1}s'.format(self.run,(end_time-start_time).seconds))
 
    def init_log(self):
        if not os.path.exists(self.test_log):
            os.mknod(self.test_log)
        logging.basicConfig(level=logging.DEBUG,
                        format='%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
                        datefmt='%a, %d %b %Y %H:%M:%S',
                        filename=self.test_log,
                        filemode='w') 
        
    def init_config(self):
        if not os.path.exists(self.test_config_path):
            raise NameError("There is a test_config path error","in test_args.py")
        else:
            self.config = ConfigParser.ConfigParser()
            self.config.read(self.test_config_path)

    def test_vjtree(self):
        """
        Run vjtree testcase.
        """
        if self.config.has_section('vjtree'):
            if not os.path.exists(self.mountpoint):
                os.mkdir(self.mountpoint)
            command = 'vjtree -d {0} '.format(self.mountpoint)
            vjtree_config = self.config.options('vjtree')
            for key in vjtree_config:
                if key == 'refrence':
                    command = command + '-r {0} '.format(self.config.get('vjtree', 'refrence'))
                if key == 'pattern':
                    command = command + '-p {0} '.format(self.config.get('vjtree', 'pattern'))
                if key == 'level':
                    command = command + '-l {0} '.format(self.config.get('vjtree', 'level'))
                if key == 'width':
                    command = command + '-w {0} '.format(self.config.get('vjtree', 'width'))
                if key == 'iosize':
                    command = command + '-i {0} '.format(self.config.get('vjtree', 'iosize'))
                if key == 'seed':
                    command = command + '-S {0} '.format(self.config.get('vjtree', 'seed'))
                if key == 'files_per_directory':
                    command = command + '-n {0} '.format(self.config.get('vjtree', 'files_per_directory'))
                if key == 'filesize':
                    command = command + '-s {0} '.format(self.config.get('vjtree', 'filesize'))

            command_vjtree = command
            if self.config.get('vjtree','write') == str(True):
                command = command_vjtree + '-W 2>&1|tee -a {0}'.format(self.test_log)
                logging.info('start vjtree create...')
                logging.info(command)
                vjtree_create_start = datetime.datetime.now()
                vjtree_create_status, vjtree_create_output = commands.getstatusoutput(command)
                logging.info(vjtree_create_output)
                vjtree_create_end = datetime.datetime.now()
                logging.info('perform test vjtree create time: {0}s'.format((vjtree_create_end-vjtree_create_start).seconds))

            if self.config.get('vjtree','read') == str(True):
                command = command_vjtree + '-R 2>&1|tee -a {0}'.format(self.test_log)
                logging.info('start vjtree read...')
                logging.info(command)
                vjtree_read_start = datetime.datetime.now()
                vjtree_read_status, vjtree_read_output = commands.getstatusoutput(command)
                logging.info(vjtree_read_output)
                vjtree_read_end = datetime.datetime.now()
                logging.info('perform test vjtree create time: {0}s'.format((vjtree_read_end-vjtree_read_start).seconds))

            if self.config.get('vjtree','verify') == str(True):
                command = command_vjtree + '-V 2>&1|tee -a {0}'.format(self.test_log)
                logging.info('start vjtree verify...')
                logging.info(command)
                vjtree_verify_start = datetime.datetime.now()
                vjtree_verify_status, vjtree_verify_output = commands.getstatusoutput(command)
                logging.info(vjtree_verify_output)
                vjtree_verify_end = datetime.datetime.now()
                logging.info('perform test vjtree create time: {0}s'.format((vjtree_verify_end-vjtree_verify_start).seconds))

            if self.config.get('vjtree', 'delete') == str(True):
                command = command_vjtree + '-U 2>&1|tee -a {0}'.format(self.test_log)
                logging.info('start vjtree delete...')
                logging.info(command)
                vjtree_delete_start = datetime.datetime.now()
                vjtree_delete_status, vjtree_delete_output = commands.getstatusoutput(command)
                logging.info(vjtree_create_output)
                vjtree_delete_end = datetime.datetime.now()
                logging.info('perform test vjtree create time: {0}s'.format((vjtree_delete_end-vjtree_delete_start).seconds))
              
                commands.getstatusoutput('cp {0}/* ../ && rm -rf {0}'.format(self.mountpoint))
            end_time = datetime.datetime.now()
            logging.info('End test {0}...'.format(self.run))
            logging.info('perform test {0} case of time: {1}s'.format(self.run,(end_time-self.start_time).seconds))
            
    def test_iozone(self):
        """
        Run iozone testcase.
        """
        if self.config.has_section('iozone'):
            if not os.path.exists(self.mountpoint):
                os.mkdir(self.mountpoint)
            command = 'iozone '
            iozone_config = self.config.options('iozone')
            for key in iozone_config:
                if key == 'write_rewrite' and self.config.get('iozone','write_rewrite') == str(True):
                    command = command + '-i 0 '
                if key == 'read_reread' and self.config.get('iozone','read_reread') == str(True):
                    command = command + '-i 1 '
                if key == 'record_size':
                    command = command + '-r {0} '.format(self.config.get('iozone','record_size'))
                if key == 'file_size':
                    command = command + '-s {0} '.format(self.config.get('iozone','file_size'))
                if key == 'unlink' and self.config.get('iozone','unlink') != str(True):
                    command = command + '-w '
                if key == 'not_retests' and self.config.get('iozone','not_retests') == str(True):
                    command = command + '-+n '
                if key == 'threads':
                    command = command + '-t {0} '.format(self.config.get('iozone','threads'))
                if key == 'filenames':
                    command = command + '-F '
                    for i in range(0, int(self.config.get('iozone','threads'))):
                        command = command + '{0}/{1}_{2} '.format(self.mountpoint, self.config.get('iozone','filenames'), i)
         
            command = command + '2>&1|tee -a {0}'.format(self.test_log)
            logging.info(command)
            iozone_status, iozone_output = commands.getstatusoutput(command)    
            end_time = datetime.datetime.now()
            logging.info('End test {0}...'.format(self.run))
            logging.info('perform test {0} case of time: {1}s'.format(self.run,(end_time-self.start_time).seconds))

    def test_rsync(self):
        """
        Run rsync test
        """
        if self.config.has_section('rsync'):
            if not os.path.exists(self.mountpoint):
                os.mkdir(self.mountpoint)
            command = 'rsync -a '
            rsync_config = self.config.options('rsync')
            for key in rsync_config:
                if key == 'archive_from':
                    command = command + '{0} '.format(self.config.get('rsync','archive_from'))
    
            rsync_command = command
            if 'loops' in rsync_config:
                for i in range(0, int(self.config.get('rsync','loops'))):
                    test_rsync = rsync_command + '{0}/{1} 2>&1|tee -a {2}'.format(self.mountpoint, i, self.test_log) 
                    logging.info(test_rsync)
                    rsync_status, rsync_output = commands.getstatusoutput(test_rsync)
            if 'unlink' in rsync_config and self.config.get('rsync', 'unlink') == str(True):
                test_rsync_delete = 'rm -rf {0} '.format(self.mountpoint)
                logging.info(test_rsync_delete)
                rsync_delete_status, rsync_delete_output = commands.getstatusoutput(test_rsync_delete)
                logging.info(rsync_delete_output)

            end_time = datetime.datetime.now()
            logging.info('End test {0}...'.format(self.run))
            logging.info('perform test {0} case of time: {1}s'.format(self.run,(end_time-self.start_time).seconds))

    def test_fsstress(self):
        """
        Run fsstress testcase.
        """
        if self.config.has_section('fsstress'):
           command = 'fsstress -d {0} '.format(self.mountpoint)
           fsstress_config = self.config.options('fsstress')
           for key in fsstress_config:
               if key == 'loops':
                   command = command + '-l {0} '.format(self.config.get('fsstress','loops'))
               if key == 'nops':
                   command = command + '-n {0} '.format(self.config.get('fsstress','nops'))
               if key == 'nproc':
                   command = command + '-p {0} '.format(self.config.get('fsstress','nproc'))
               if key == 'verbose_mode' and self.config.get('fsstress', 'verbose_mode') == str(True):
                   command = command + '-v '
               if key == 'unlink' and self.config.get('fsstress','unlink') != str(True):
                   command = command + '-c '

           command = command + '2>&1|tee -a {0}'.format(self.test_log)
           logging.info(command)
           fsstress_status, fsstress_output =  commands.getstatusoutput(command)
           if self.config.get('fsstress','unlink') and self.config.get('fsstress','unlink') == str(True):
               commands.getstatusoutput('rm -rf {0}'.format(self.mountpoint))
           end_time = datetime.datetime.now()
           logging.info('End test {0}...'.format(self.run))
           logging.info('perform test {0} case of time: {1}s'.format(self.run,(end_time-self.start_time).seconds))
           
    def test_mdtest(self):
        """
        Run mdtest testcase.
        """
        if self.config.has_section('mdtest'):
            command = 'mdtest -d {0} '.format(self.mountpoint)
            mdtest_config = self.config.options('mdtest')
            for key in mdtest_config:
                if key == 'depth':
                    command = command + '-z {0} '.format(self.config.get('mdtest','depth'))
                if key == 'branch':
                    command = command + '-b {0} '.format(self.config.get('mdtest','branch'))
                if key == 'bytes_to_write':
                    command = command + '-w {0} '.format(self.config.get('mdtest','bytes_to_write'))
                if key == 'items_directory':
                    command = command + '-I {0} '.format(self.config.get('mdtest', 'items_directory'))
                if key == 'randomly' and self.config.get('mdtest', 'randomly') == str(True):
                    command = command + '-R '
                if key == 'only_create' and self.config.get('mdtest', 'only_create') == str(True):
                    command = command + '-C ' 
            command = command + '2>&1|tee -a {0}'.format(self.test_log)
            logging.info(command)
            mdtest_status, mdtest_output = commands.getstatusoutput(command)
            if self.config.get('mdtest', 'only_create') and self.config.get('mdtest', 'only_create') != str(True):
                commands.getstatusoutput('rm -rf {0}'.format(self.mountpoint))

            end_time = datetime.datetime.now()
            logging.info('End test {0}...'.format(self.run))
            logging.info('perform test {0} case of time: {1}s'.format(self.run,(end_time-self.start_time).seconds))

    def test_pjd(self):
        """
        Run pjd testcase.
        """
        if self.config.has_section('pjd'):
            if not os.path.exists(self.mountpoint):
                os.mkdir(self.mountpoint)
            command = 'cd {0} && prove -v -r /tests/pjd-fstest/tests 2>&1|tee -a {1}'.format(self.mountpoint, self.test_log)
            logging.info(command)
            pjd_status, pjd_output = commands.getstatusoutput(command)
            logging.info(pjd_output)

            if self.config.get('pjd', 'unlink') == str(True):
                command_delete = 'rm -rf {0}'.format(self.mountpoint)
                logging.info(command_delete)
                pjd_delete_status, pjd_delete_output = commands.getstatusoutput(command_delete)
                logging.info(pjd_delete_output)
            
            end_time = datetime.datetime.now()
            logging.info('End test {0}...'.format(self.run))
            logging.info('perform test {0} case of time: {1}s'.format(self.run,(end_time-self.start_time).seconds))

    def test_fio(self):
        """
        Run fio testcase
        """
        if self.config.has_section('fio'):
            command = 'fio -filename={0} '.format(self.mountpoint)
            fio_config = self.config.options('fio')
            for key in fio_config:
                if key == 'iodepth':
                    command = command + '-iodepth {0} '.format(self.config.get('fio', 'iodepth'))
                if key == 'thread' and self.config.get('fio', 'thread') == str(True):
                    command = command + '-thread '
                if key == 'rw':
                    command = command + '-rw={0} '.format(self.config.get('fio', 'rw'))
                if key == 'ioengine':
                    command = command + '-ioengine={0} '.format(self.config.get('fio', 'ioengine'))
                if key == 'bs':
                    command = command + '-bs={0} '.format(self.config.get('fio', 'bs'))
                if key == 'size':
                    command = command + '-size={0} '.format(self.config.get('fio', 'size'))
                if key == 'numjobs':
                    command = command + '-numjobs={0} '.format(self.config.get('fio', 'numjobs'))
                if key == 'runtime':
                    command = command + '-runtime={0} '.format(self.config.get('fio', 'runtime'))
                if key == 'group_reporting' and self.config.get('fio', 'group_reporting') == str(True):
                    command = command + '-group_reporting '
            command = command + '-name={0}-{1} 2>&1|tee -a {2} '.format(self.config.get('fio', 'rw'), self.config.get('fio', 'ioengine') , self.test_log)
            logging.info(command)
            fio_status, fio_output = commands.getstatusoutput(command)

            end_time = datetime.datetime.now()
            logging.info('End test {0}...'.format(self.run))
            logging.info('perform test {0} case of time: {1}s'.format(self.run,(end_time-self.start_time).seconds))

    def test_smallfile(self):
        """
        Run smallfile testcase
        """
        if self.config.has_section('smallfile'):
            if not os.path.exists(self.mountpoint):
                os.mkdir(self.mountpoint)
            command = 'python /tests/smallfile/smallfile_cli.py --top {0} '.format(self.mountpoint)
            smallfile_config = self.config.options('smallfile')
            self.config.get('smallfile','create') == str(True)

            for key in smallfile_config:
                if key == 'files_per_dir':
                    command = command + '--files-per-dir {0} '.format(self.config.get('smallfile', 'files_per_dir'))
                if key == 'files':
                    command = command + '--files {0} '.format(self.config.get('smallfile', 'files'))
                if key == 'threads':
                    command = command + '--threads {0} '.format(self.config.get('smallfile', 'threads'))
                if key == 'file_size':
                    command = command + '--file-size {0} '.format(self.config.get('smallfile', 'file_size'))
                if key == 'record_size':
                    command = command + '--record-size {0} '.format(self.config.get('smallfile', 'record_size'))

            command_pre = command

            if self.config.get('smallfile','create') == str(True):
                command_create = command_pre + '--operation create ' + '2>&1|tee -a {0}'.format(self.test_log)
                logging.info('start smallfile create...')
                logging.info(command_create)
                smallfile_create_start = datetime.datetime.now()
                smallfile_create_status, smallfile_create_output = commands.getstatusoutput(command_create)
                logging.info(smallfile_create_output)
                smallfile_create_end = datetime.datetime.now()
                logging.info('perform test smallfile create time: {0}s'.format((smallfile_create_end-smallfile_create_start).seconds))

            if self.config.get('smallfile','read') == str(True):
                command_read = command_pre + '--operation read ' +  '2>&1|tee -a {0}'.format(self.test_log)
                logging.info('start small read...')
                logging.info(command_read)
                smallfile_read_start = datetime.datetime.now()
                smallfile_read_status, smallfile_read_output = commands.getstatusoutput(command_read)
                logging.info(smallfile_read_output)
                smallfile_read_end = datetime.datetime.now()
                logging.info('perform test smallfile read time: {0}s'.format((smallfile_read_end-smallfile_read_start).seconds))

            if self.config.get('smallfile','delete') == str(True):
                command_delete = command_pre + '--operation delete ' +  '2>&1|tee -a {0}'.format(self.test_log)
                logging.info('start small delete...')
                logging.info(command_delete)
                smallfile_read_start = datetime.datetime.now()
                smallfile_read_status, smallfile_read_output = commands.getstatusoutput(command_delete)
                logging.info(smallfile_read_output)
                smallfile_read_end = datetime.datetime.now()
                logging.info('perform test smallfile delete time: {0}s'.format((smallfile_read_end-smallfile_read_start).seconds))

            end_time = datetime.datetime.now()
            logging.info('End test {0}...'.format(self.run))
            logging.info('perform test {0} case of time: {1}s'.format(self.run,(end_time-self.start_time).seconds))            

TestXtao(doc, sys.argv[1:])
