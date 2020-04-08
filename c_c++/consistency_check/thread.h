#ifndef __CTHREAD__
#define __CTHREAD__

#include <pthread.h>
#include <sys/types.h>

class CThread
{
private:
    int Print();
    pthread_t m_tid;
protected:
    virtual void *entry() = 0;
public:
    ~CThread()
    {
      pthread_join(m_tid, NULL);
    }
    int start();      //线程启动
    static void *_entry_func(void *arg);
};

#endif
