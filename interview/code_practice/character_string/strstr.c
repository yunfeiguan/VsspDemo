#include<stdio.h>
#include<string.h>
#include<stdlib.h>

int my_strstr(char *dest, char *sub, int *pos) 
{
    int sub_num = 0;
    char *tmp_dest = NULL;
    char *head_dest = dest, *tmp_sub = sub;
   
    if (!dest || !sub)
        return -1;
    
    if (strlen(sub) > strlen(dest)) {
        printf("Warn::sub is longger than dest!\n");
        return -1;
    }

    while (*dest != '\0') {
        if (*dest == *sub) {
            tmp_dest = dest;
            tmp_sub = sub;
            
            tmp_dest++;
            tmp_sub++;

            while (*tmp_sub != '\0' && *tmp_dest != '\0' && *tmp_dest++ == *tmp_sub++);

            if (*tmp_sub == '\0') {
                sub_num++;
                *pos++ = dest - head_dest;

                printf("found %d %s at %d\n", sub_num, sub, dest - head_dest);
            }
        }

        dest++;
    }
    return sub_num;
}

int main()
{
    int sub_num = 0, i = 0;
    int position[10] = {0};

    char *dest = "hello xtao, xtao is great company! I love xtao!";
    char *sub = "xtao";

    sub_num = my_strstr(dest, sub, position);
    printf("%s has %d %s \n", dest, sub_num, sub);

    for (i = 0; i < sub_num; i++) {
        printf("position %d is %d\n", i,*(position+i));
    }

    return 0;
}
