#include<stdio.h>
#include<string.h>

#define MAX_SIZE 1024
int main()
{
    char str[MAX_SIZE] = {'\0'};

    while (1) {
        gets(str);

        if (strcmp(str, "quit") == 0)
            return 0;
        else
            printf("input is: %s\n", str);
    }
    return 0;
}
