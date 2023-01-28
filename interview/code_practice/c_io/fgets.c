#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#define MAX_SIZE 65535
int main(int argc, char **argv)
{
    int line = 0, line_length = 0;
    char str[MAX_SIZE] = {'\0'};
    
    if (argc < 2) {
        printf("the file name is needed!\n");
        return 0;
    }

    char *file = argv[1];
    printf("filename: %s\n", file);

    FILE *stream = fopen(file, "rb"); 
    while (fgets(str, MAX_SIZE, stream) != NULL) {
        line++;
        line_length = strlen(str);
        printf("%d:%d %s", line, line_length, str);
    }
    
    return 0;
}
