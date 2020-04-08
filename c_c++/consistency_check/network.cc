#include<iostream>
#include"network.h"
#include"io_write_read.h"
using namespace std;

int Connection::Init()
{
	if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) 
	{
		cout << "Socket Error: " << strerror(errno) << endl;
		return errno;
	}

	if (net_type == 's') {
		struct epoll_event e;

		if(bind(sockfd,(struct sockaddr *)(&net_addr),sizeof(struct sockaddr))==-1){
			cout << "Bind Error: " << strerror(errno) << endl;
			return errno;
		}
		if (listen(sockfd, 50) == -1) {
			cout << "Listen Error: " << strerror(errno) << endl;
			return errno;
		}
		if ((epollfd = epoll_create(1)) == -1) {
			cout << "epoll create Error: " << strerror(errno) << endl;
			return errno;
		}
		
		memset(&e, 0, sizeof(e));
		e.events = EPOLLIN;  
		e.data.fd = sockfd;
		if (epoll_ctl(epollfd, EPOLL_CTL_ADD, sockfd, &e) == -1) {
			cout << "epoll_ctl Error: " << strerror(errno) << endl;
			return errno;
		}
	} 
	return 0;
}

int Connection::Connect()
{   
    struct epoll_event e;
	if(connect(sockfd,(struct sockaddr *)(&net_addr),sizeof(struct sockaddr))==-1) {
		cout << "Connect Error: " << strerror(errno) << endl;
		return errno;
	}
    cout << "INFO: >> connect sucess fd: " << sockfd << endl;

    if ((epollfd = epoll_create(1)) == -1) {
        cout << "epoll create Error: " << strerror(errno) << endl;
        return errno;
    }

    memset(&e, 0, sizeof(e));
    e.events = EPOLLIN;
    e.data.fd = sockfd;
    if (epoll_ctl(epollfd, EPOLL_CTL_ADD, sockfd, &e) == -1) {
        cout << "epoll_ctl Error: " << strerror(errno) << endl;
        return errno;
    }
    while (1) {
        while (1) {
            struct epoll_event ev[1024];
            int n = epoll_wait(epollfd, ev, 1024, 10);
            if (n == 0)
                continue;
            else if (n < 0) {
                cout << "epoll_wait Error: " << strerror(errno) << endl;
                break;
            }

            int m = min(n, 1024);
            for (int i = 0; i < m; i++) {
                //cout << "fd is " << ev[i].data.fd << endl;
                if (ev[i].data.fd == sockfd) {
                    Read_data(ev[i].data.fd);
                    //cout << "INFO: >> client recieve:" << buf << endl;

                    // start write
                    if (strcmp(buf, "write") == 0) {
                        wr->cond.Signal();
                    }
                }
            }
        }
    }
}

void *Connection::NetThread::entry()
{
   _con->entry();
}

void *Connection::entry()
{
	while(1) {
		struct sockaddr_in clientaddr;
		struct epoll_event e;  
		socklen_t addrlen;
		int newfd = accept(sockfd, (struct sockaddr *)&clientaddr, &addrlen);
		
		cout << "new client connected: " << inet_ntoa(clientaddr.sin_addr) << ":" 
			<< ntohs(clientaddr.sin_port) << " fd: " << newfd << endl;
		int oldflag = fcntl(newfd, F_GETFL, 0);  
        int newflag = oldflag | O_NONBLOCK;  
        if (fcntl(newfd, F_SETFL, newflag) == -1)  
        {  
            cout << "fcntl error, oldflag =" << oldflag << ", newflag = " << newflag << endl; 
            continue;  
        }
        
        client_fd = newfd;
        memset(&e, 0, sizeof(e));  
        e.events = EPOLLIN | EPOLLHUP | EPOLLET;  
        e.data.fd = newfd;  
        if (epoll_ctl(epollfd, EPOLL_CTL_ADD, newfd, &e) == -1)  
        {  
            cout << "epoll_ctl error, fd =" << newfd << endl;  
        }
    }
    return NULL;
}

int Connection::Send_data(int fd, const char *str)
{
	int r = 0;

    //cout << "Send_data fd: "<< fd << " " << str << endl;
	if (str) {
		if ((r = write(fd, str, strlen(str))) == -1) {
			cout << "Write Error: " << strerror(errno) << endl;
			shutdown(sockfd, SHUT_WR);	/* send FIN */
			return errno;			
		}
	}
	return r;
}

int Connection::Read_data(int fd)
{
	int r = 0;
    memset(buf, '\0', MAXLEN);	
	if ((r = read(fd, buf, MAXLEN)) == -1) {
		cout << "Read Error: " << strerror(errno) << endl;
		shutdown(fd, SHUT_WR);	/* send FIN */
		return errno;
	}
    //cout << "data is : " << buf  << endl;
	return r;
}

char * Connection::Get_cap_data()
{
	return buf;
}
