// CThread.cpp

#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include "thread.h"
#include <stdlib.h>

int CThread::Print()
{
    for(int i=0; i<10; ++i)
    {
        sleep(1);
        printf("aaaaaaaaaa-----\n");
    }
    return 0;
}

void * CThread::_entry_func(void *arg)
{
    void *r = ((CThread*)arg)->entry();
    return r;
}

int CThread::start()
{
    //pthread_create(&m_tid, NULL, _entry_func, (void*)this);
    pthread_create(&m_tid, NULL, _entry_func, (void*)this);
    return 0;
}
