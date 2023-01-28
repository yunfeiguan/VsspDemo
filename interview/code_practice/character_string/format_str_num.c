#include<stdio.h>
#include<string.h>
#include<stdlib.h>

#define MAX_SIZE 1024

void format_str(char *old_str, char *new_str)
{
    int str_length = 0, i = 0;
    char character_len = 0;
    char *p = old_str;

    while (*p) {
        new_str[i++] = *p;
        character_len++;
        
        if (*(p+1) && *p != *(p+1)) {
            new_str[i++] = character_len + '0';
            character_len = 0;
        }
        p++;
    }

    new_str[i++] = character_len + '0';
    new_str[i] = '\0';
}

int main()
{
    char str_old[MAX_SIZE] = {'\0'}; 
    char str_new[MAX_SIZE] = {'\0'}; 

    while (1) {
        gets(str_old);
        printf("input str is: %s\n", str_old);

        format_str(str_old, str_new);
        printf("after fromat is: %s\n", str_new);
    }
    return 0;
}
