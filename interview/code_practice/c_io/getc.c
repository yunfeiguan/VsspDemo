#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#define MAX_SIZE 65535
int main(int argc, char **argv)
{
    char c = '0';
    int line = 0, line_length = 0;
    char str[MAX_SIZE] = {'\0'};
    
    if (argc < 2) {
        printf("the file name is needed!\n");
    }

    char *file = argv[1];
    printf("filename: %s\n", file);

    FILE *stream = fopen(file, "rb"); 
    while ((c = getc(stream)) != EOF) {
        str[line_length] = c;
        line_length++;
        
        if (c == '\n') {
            line++;
            printf("%d:%d %s", line, line_length, str);
            line_length = 0;
            memset(str, '\0', MAX_SIZE);
        }
    }
    
    return 0;
}
