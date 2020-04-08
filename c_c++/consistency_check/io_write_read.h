#ifndef __MAIN__
#define __MAIN__

#include<stdio.h>
#include<fcntl.h>
#include<unistd.h>
#include<sys/types.h>
#include<sys/stat.h>
#include<error.h>
#include<string.h>
#include<string>
#include"network.h"
#include"time.h"
#include"mutex_cond.h"
#include <unistd.h> 

#define BUF_LEN 4048576

class Connection;
using namespace std;
class IOWriteRead   
{
  string cap;
  char writting;
  char buf[BUF_LEN];
  char read_buf[BUF_LEN];
  Connection *con;
  public:
  string file;
  string file2;
  int fd, fd2;
  Mutex lock;
  Mutex write_lock;
  Cond cond;
  Cond write_cond;
  Time t;

  class IoWorkerThread : public CThread {
    public:
      IOWriteRead *wr;
      explicit IoWorkerThread(IOWriteRead *wr_) : wr(wr_) {}
      void *entry() 
      {   
        int r = 0;
        cout << "INFO: >> welcome io worker entry " << wr->fd << endl;
        while (1) {
          if (wr->con->net_type == 's') {
            // A B B A lock mode
            // hold lock
            wr->lock.lock();
            while (!(wr->can_write())) {
              wr->cond.Wait(wr->lock);
            }

            // hold write_lock
            wr->write_lock.lock(); // hold write_lock

            // do something ...
            wr->set_write_flag('1');
            wr->write_file(wr->fd, 1);
            wr->set_write_flag('0');
            wr->write_cond.Signal();

            // release write_lock
            wr->write_lock.unlock();

            // release lock
            wr->lock.unlock();
          } else if (wr->con->net_type == 'c') {
            wr->con->Send_data(wr->con->sockfd, "wait");
            cout << "INFO: >> send WAIT COMANND to server." << endl;

            // hold lock, i'm waiting "write" command from server, 
            // so don't need to declare and judge variable.
            wr->lock.lock();
            wr->cond.Wait(wr->lock);
            wr->lock.unlock();

            cout << "INFO: >> client start write file " << endl;
            wr->write_file(wr->fd, 1);

            // for invalidate self fuse kernel page cache
            wr->file_reopen(wr->file, wr->fd);

            // sleep 10 senconds to see if client A still write data to file1 
            sleep(10);
            // and don't need to wirte file2
            //wr->write_file(wr->fd2, 50);

            wr->read_data(wr->fd);
            if ((r = wr->do_check()) < 0) {
              cout << "ERR: >> Check error, exit ..." << endl;
              break; 
            }

            sleep(10);
            cout << "INFO: >> Send WRITE COMANND to start next loop!" << endl;
            wr->con->Send_data(wr->con->sockfd, "write");
            sleep(20);
          }
        }
      }
  }io_worker_thread;

  IOWriteRead(string &name, string &name2, Connection *con_):file(name),file2(name2), writting('0'),
  con(con_),io_worker_thread(this)
  {	
    if ((fd = open(file.c_str(), O_RDWR, 0666)) == -1)
    {
      cout << "can't open file " <<  file << endl;
    }
    cout << "INFO: Open file ok: " <<  file << endl;
    /*
       if ((fd2 = open(file2.c_str(), O_RDWR, 0666)) == -1)
       {
       cout << "can't open file " <<  file2 << endl;
       }*/
    cap = "write";
    if (con->net_type == 's')
      memset(buf, 's', BUF_LEN);
    else
      memset(buf, 'c', BUF_LEN);
  }

  void file_reopen(string file_name, int fd)
  {
    int r = 0;
    if ((r = close(fd)) == -1) {
      cout << "file "<< file_name << " close Error: " 
        << strerror(errno) << endl;
    }
    if ((fd = open(file_name.c_str(), O_RDWR, 0666)) == -1)
    {
      cout << "can't open file " <<  file << endl;
    }
  }

  void set_cap(const char *c)
  {
    cap = c;
  }

  bool can_write()
  {
    string c = cap;

    return  (c == "write");
  }

  bool is_writting()
  {
    char f = writting;

    return (f == '1');
  }

  void set_write_flag(char flag)
  {
    writting = flag;
  }

  int write_file(int fd, int block_num)
  {  
    int r = 0, written_blocks = 0;
    while (block_num--) {
      cout << "DEBUG: " << t.time() << " write start ..."<< endl;
      r = pwrite(fd, buf, BUF_LEN, 0);
      written_blocks++;
    }
    cout << "INFO:  " << t.time() << " write ----------- OK: fd: " << fd << " "<< written_blocks * r << 
      ": "<< buf[0] << " writting: " << writting << endl;
  }

  int read_data(int fd)
  {
    int r = pread(fd, read_buf, BUF_LEN, 0);
    cout << "read ------------- OK: fd: " << fd << " " << r << ": "<< buf[0] << endl;
  }

  int do_check()
  {
    unsigned char c, t;
    unsigned i = 0, offset = 0;
    unsigned n = 0, size = BUF_LEN;
    unsigned bad = 0;
    unsigned offset_my = offset;

    cout << "INFO: >> Start checking ... "<<endl;
    if (memcmp(buf + offset, read_buf, size) != 0)
    {
      cout << "INFO: >> Check Result: Error ... "<<endl;
      while (size > 0)
      {
        c = buf[offset];
        t = read_buf[i];
        if (c != t) {
          if (n < 10) {
            printf("good_buf[0x%5x]: 0x%x \t\t read_buf[%d]: 0x%x \n",
                offset, buf[offset], i, read_buf[i]);
          }
          n++;
        }

        offset++;
        i++;
        size--;
      }
      return -1;
    }
    cout << "INFO: >> Check Result: Very Good! Congratulations!... \n\n"<<endl;
    return 0;
  }
};

#endif
