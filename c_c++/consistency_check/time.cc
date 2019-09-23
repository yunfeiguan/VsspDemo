#include <iostream>
#include <sys/time.h>
#include <sstream>
#include <cstring>
#include "time.h"

using namespace std;

//GetCurrentFormatTimeString
string Time::time()
{
  std::stringstream    ss;

  gettimeofday(&tv, NULL);

  memset(timeArray, 0, sizeof(timeArray));

  strftime(timeArray, sizeof(timeArray) - 1, "%F %T", localtime(&tv.tv_sec));

  ss << string(timeArray) << "." << tv.tv_usec;

  return ss.str();
}
