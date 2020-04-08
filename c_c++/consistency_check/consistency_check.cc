#include<iostream>
#include<stdio.h>
#include"io_write_read.h"
#include"time.h"
#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/epoll.h>
#include <pthread.h>
#include <unistd.h>
#include<getopt.h>

using namespace std;

pthread_cond_t accept_cond;

void usage(void)
{
  fprintf(stdout, "Usage: %s",
      "consistency_check <-t type> <--ip addr> <-f file>\n\n\
      -t type: specify s/c of the routine, the server start write first and \n\
      and the client will notify server stop write, then write the \n\
      same file and do read and check.\n\n\
      -f file: the file name we will do IO.\n\n\
      --ip addr: the ip of server.\n\n\
      expample:\
      consistency_check -t s --ip 192.168.12.201\n\n\
      consistency_check -t c --ip 192.168.12.201\n\n");
}
static struct option long_options[] = {
  {"ip", required_argument, NULL, 'i'},
};

int main(int argc, char **argv)
{
  struct sockaddr_in servaddr;
  string name;
  char *ip_addr;
  char type;
  int opt;

  if (argc < 3) {
    usage();
    return -1;
  }

  while((opt =getopt_long(argc,argv,"t:f:",long_options, NULL))!= -1)
  {
    switch(opt) {
      case 't':
        type = optarg[0];
        break;
      case 'f':
        name = optarg; 
        break;
      case 'i':
        ip_addr = optarg;
        break;
defaul:
        usage();
    }
  }

  cout << "+----------------------------------------------------------------------------+" << endl;
  cout << "|Type: " << type << "  IP: " << ip_addr << "  file: " << name << endl;;
  cout << "+----------------------------------------------------------------------------+" << endl;

  pthread_cond_init(&accept_cond, NULL);
  string name2 = name;

  Connection *con = new Connection(type, ip_addr);

  IOWriteRead *wr = new IOWriteRead(name, name2, con);

  con->wr = wr;
  con->Init();

  /*
     cout<< "INFO: >> wait 10 sencods ..." << endl;
     sleep(10);
     cout<< "INFO: >> waiting end, start do io ..." << endl;
   */

  wr->io_worker_thread.start();

  // server will wait here recieve new client connect and client data.
  if (type == 's') {
    con->net_thread.start();
    while (1) {
      struct epoll_event ev[1024];
      int n = epoll_wait(con->epollfd, ev, 1024, 10);
      if (n == 0)
        continue;
      else if (n < 0) {
        cout << "epoll_wait Error: " << strerror(errno) << endl;
        break;
      }

      int m = min(n, 1024);
      for (int i = 0; i < m; i++) {
        if (ev[i].data.fd == con->client_fd) {
          con->Read_data(con->client_fd);
          char *data = con->Get_cap_data();
          //cout << "server recieved: " << data << endl;
          if (strcmp(data, "wait") == 0)
          { 
            cout << "INFO: >> recieve WAIT COMANND, will hold wirte" << endl;
            wr->set_cap("wait");

            wr->write_lock.lock();
            while (wr->is_writting()) {
              cout << "INFO: >> server is writting wait here..." << endl;
              wr->write_cond.Wait(wr->write_lock);
            }
            wr->write_lock.unlock();

            // let client start write
            con->Send_data(con->client_fd, "write"); 
            cout << "INFO: >> Let client start write!\n\n" << endl;
          } else if (strcmp(data, "write") == 0) {
            cout << "INFO: >> recieve WRITE COMMAND, will start wirte" << endl;

            wr->lock.lock();
            wr->set_cap("write");
            wr->cond.Signal();
            wr->lock.unlock();
          }
        }
      }
    }
  } else if (type == 'c') {
    con->Connect();
    for(;;);
  }
}
