#ifndef __TIME_H__
#define __TIME_H__

#include <iostream>
#include <sys/time.h>
#include <sstream>
#include <cstring>

class Time {
  struct timeval  tv;
  char            timeArray[40];
public:
  std::string time();
};
#endif
