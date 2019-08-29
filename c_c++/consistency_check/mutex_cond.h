#ifndef __COND__
#define __COND__

#include<pthread.h>
#include<assert.h>
#include<iostream>


class Mutex
{
public:
    pthread_mutex_t _m;

    Mutex() { 
        int r = pthread_mutex_init(&_m, NULL); 
        assert(r == 0);
//        std::cout<< "init Mutex " << std::endl;
    }
    ~Mutex() {
        pthread_mutex_destroy(&_m);
    }

    void lock() {
        int r = pthread_mutex_lock(&_m);
        assert(r == 0);
    }
    
    void unlock() {
        int r = pthread_mutex_unlock(&_m);
        assert(r == 0);
    }
};
class Cond  {
    Mutex *waiter_mutex;
    pthread_cond_t _c;

public:
    Cond() : waiter_mutex(NULL) {
        int r = pthread_cond_init(&_c, NULL);
        assert(r == 0);
  //      std::cout<< "init Cond " << std::endl;
    }

    virtual ~Cond() {
        pthread_cond_destroy(&_c);
    }

    int Wait(Mutex &mutex) {
        assert(waiter_mutex == NULL || waiter_mutex == &mutex);
        waiter_mutex = &mutex;

        int r = pthread_cond_wait(&_c, &mutex._m);
        return r;
    }

    int Signal() { 
        // make sure signaler is holding the waiter's lock.
        int r = pthread_cond_signal(&_c);
        return r;
    }
};



#endif
