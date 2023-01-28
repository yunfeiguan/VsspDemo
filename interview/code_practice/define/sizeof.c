#include<stdio.h>
#include<iostream>

#define ARR_SIZE( a ) ( sizeof(a) / sizeof(a[0]))


void array_size(int (&a)[100])
{
    printf("user size is %lu\n", ARR_SIZE(a));
}
int main()
{
    int user[100] = {0};

    printf("main user size is %lu\n", ARR_SIZE(user));

    array_size(user);
    return 0;
}
