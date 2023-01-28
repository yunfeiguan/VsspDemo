#include<stdio.h>
#include<string.h>
#include<stdlib.h>

int my_strstr(char *long_str, char *short_str)
{
    int i = 0;
    char *tmp_long = long_str, *tmp_short = short_str;
    char *start_pos = long_str;
     
    while (*long_str) {
        if (*long_str == *short_str) {
            tmp_long = long_str + 1;
            tmp_short = short_str + 1;

            while (*tmp_short && *tmp_long && *tmp_long++ == *tmp_short++); 
        }

        if (*tmp_short == '\0') 
            return (long_str - start_pos);

        long_str++;
    }
    return 0;
}

int max_common_str(char *src, char *dst)
{
    int i = 0, j = 0, comm_len = 0, short_len = 0;
    char *long_str = src;
    char *short_str = dst;
    char comm[100] = {'\0'};

    if (strlen(src) < strlen(dst)) {
        long_str = dst;
        short_str = src;
    }
    
    if (my_strstr(long_str, short_str)) {
        printf("found the comm: %s\n", short_str);
        return 1;
    }

    short_len = strlen(short_str);
    for (i = short_len - 1; i > 0; i--) {
        for (j = 0; j <= short_len - i; j++) {
          memcpy(comm, (short_str + j), i);
          
          if (my_strstr(long_str, comm)) {
            printf("found the comm: %s\n", comm);
            return 1;
          }

          memset(comm, '\0', 100);
        }
    }

    return 0;
}

int main()
{
    char long_str[100] = {'\0'};
    char short_str[100] = {'\0'};
    //char *long_str = "guanyunfei";
    //char *short_str = "yun";
    while(1) {
        gets(long_str);
        gets(short_str);

        printf("long is %s\n", long_str);
        printf("short is %s\n", short_str);
        if (!max_common_str(long_str, short_str)) { 
            printf("didn't hos common str!\n");
            return 0;
        }
    }

    return 0;

}
