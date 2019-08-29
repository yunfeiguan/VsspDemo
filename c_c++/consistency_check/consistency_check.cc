#include<iostream>
#include<stdio.h>
#include"io_write_read.h"
//#include"network.h"
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
        --ip addr: the ip of server.\n\n");
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
	//type = argv[1][0];
    
    cout << "+----------------------------------------------------------------------------+" << endl;
    cout << "|Type: " << type << "  IP: " << ip_addr << "  file: " << name << endl;;
    cout << "+----------------------------------------------------------------------------+" << endl;

	pthread_cond_init(&accept_cond, NULL);
	string name2 = name;
    
    Connection *con = new Connection(type, ip_addr);

	IOWriteRead *wr = new IOWriteRead(name, name2, con);
    
    con->wr = wr;	
	con->Init();
	
	wr->io_worker_thread.start();

	if (type == 's') {
		//pthread_create(&accept_threadid, NULL, Connection::Accept, (void*)wr);
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
                /*cout << "fd is " << ev[i].data.fd << endl;
				if (ev[i].data.fd == con->sockfd) {
					pthread_cond_signal(&accept_cond);
				} else*/ 
                if (ev[i].data.fd == con->client_fd) {
                    con->Read_data(con->client_fd);
                    char *data = con->Get_cap_data();
                    cout << "main " << data << endl;
					if (strcmp(data, "wait") == 0)
					{   
                        cout << "recieve wait and will hold wirte" << endl;
						wr->set_cap("wait");

                        // let client start write
                        con->Send_data(con->client_fd, "write"); 
                        cout << "let client start write" << endl;
                    } else if (strcmp(data, "write") == 0) {
                        cout << "recieve write and will start wirte" << endl;
                        wr->set_cap("write");
                        wr->cond.Signal();
                    }
                }
            }
        }
    } else if (type == 'c') {
        con->Connect();
        for(;;);
    }
}
