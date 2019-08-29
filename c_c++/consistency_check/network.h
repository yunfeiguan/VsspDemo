#ifndef NETWORK_H_
#define NETWORK_H_
#include<stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <sys/epoll.h>
#include <fcntl.h>
#include "thread.h"
#define MAXLEN	  1024
#define LISTENLEN 10
#define SERV_PORT 6666

class IOWriteRead;
//class Connection : public CThread {
class Connection {
public:
	char net_type;
	int sockfd, epollfd;
    int client_fd;
    struct sockaddr_in net_addr;
    char buf[MAXLEN];
    IOWriteRead *wr;
    class NetThread : public CThread {
        Connection *_con;
        public:
        explicit NetThread(Connection *con_) :_con(con_) {}
        void *entry();
    }net_thread;
    Connection(char type, char *addr) : net_thread(this)
    {
		net_type = type;
		net_addr.sin_family = AF_INET;
		net_addr.sin_port = htons(SERV_PORT);
		
		if (net_type == 's') {
			net_addr.sin_addr.s_addr = inet_addr(addr);
		} else if (net_type == 'c') {
			net_addr.sin_addr.s_addr = inet_addr(addr);
		}
	}
	~Connection(){}
	int Init();
	int Connect();
	void *entry();
	int Send_data(int fd, const char *str);
	int Read_data(int fd);
	char *Get_cap_data();
};

#endif 
