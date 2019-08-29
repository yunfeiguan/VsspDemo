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
#include"mutex_cond.h"
#include <unistd.h> 

#define BUF_LEN 4048576

class Connection;
using namespace std;
class IOWriteRead   
{
	string cap;
	char buf[BUF_LEN];
	char read_buf[BUF_LEN];
    Mutex lock;
    Connection *con;
public:
	string file;
	string file2;
	int fd, fd2;
    Cond cond;
    
    class IoWorkerThread : public CThread {
    public:
        IOWriteRead *wr;
        explicit IoWorkerThread(IOWriteRead *wr_) : wr(wr_) {}
        void *entry() 
        {   
            cout << "welcome io worker entry " << wr->fd << endl;
            while (1) {
                if (wr->con->net_type == 's') {
                    if (wr->can_write()) {
                        wr->write_file(wr->fd, 10);
                        //sleep(5);
                    } else {
                        wr->lock.lock();
                        wr->cond.Wait(wr->lock);
                        wr->lock.unlock();
                    }
                } else if (wr->con->net_type == 'c') {
                    wr->con->Send_data(wr->con->sockfd, "wait");
                    cout << "send wait " << endl;
                    
                    wr->lock.lock();
                    wr->cond.Wait(wr->lock);
                    wr->lock.unlock();

                    cout << "start write file " << endl;
                    wr->write_file(wr->fd, 1);

                    // for invalidate self fuse kernel page cache
                    wr->file_reopen(wr->file, wr->fd);

                    // sleep 10 senconds to let client A flush fuse kernel dirty page
                    // and don't need to wirte file2
                    sleep(10);
                    //wr->write_file(wr->fd2, 50);

                    wr->read_data(wr->fd);
                    wr->do_check();
                    sleep(10);
                    cout << "send write " << endl;
                    wr->con->Send_data(wr->con->sockfd, "write");
                    sleep(20);
                }
            }
        }
    }io_worker_thread;

    IOWriteRead(string &name, string &name2, Connection *con_):file(name),file2(name2),
        con(con_),io_worker_thread(this)
	{	
		if ((fd = open(file.c_str(), O_RDWR, 0666)) == -1)
		{
			cout << "can't open file " <<  file << endl;
		}
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
        lock.lock();
		cap = c;
        lock.unlock();
	}
	
    bool can_write()
	{
        lock.lock();
        string c = cap;
        lock.unlock();
		return  (c == "write");
    }

	int write_file(int fd, int block_num)
	{  
        int r = 0, written_blocks = 0;
        while (block_num--) {
		    r = pwrite(fd, buf, BUF_LEN, 0);
            written_blocks++;
        }
		cout << "write sucess: fd: " << fd << " "<< written_blocks * r << ": "<< buf[0] << endl;
	}
	
	int read_data(int fd)
	{
		int r = pread(fd, read_buf, BUF_LEN, 0);
		cout << "read sucess: fd: " << fd << " " << r << ": "<< buf[0] << endl;
	}

	int do_check()
	{
		unsigned char c, t;
		unsigned i = 0, offset = 0;
		unsigned n = 0, size = BUF_LEN;
		unsigned bad = 0;
		unsigned offset_my = offset;

		if (memcmp(buf + offset, read_buf, size) != 0)
		{
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
		return 0;
	}
};

#endif
