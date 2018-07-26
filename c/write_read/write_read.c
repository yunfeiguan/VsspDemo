#include<stdio.h>
#include<fcntl.h>
#include<unistd.h>
#include<sys/types.h>
#include<sys/stat.h>
#include<error.h>
#include<string.h>

int fd = 0;
char buf[1024]={0};
char read_buf[1024]={0};
int num = 0;

void fill_buf(char *buf, char chars, int len)
{
    int i = 0;
    for (i=0; i < len; i++)
        buf[i] = chars;
}

void print_buf(char *buf, int len)
{
    int i = 0;
    for (i=0; i < len; i++)
        printf("buf[%d]:%c \n", i, buf[i]);
}

int compare_buf(char *src, char *dest, int len)
{
    int i = 0;
    int diff = 0;
    for (i=0; i<len; i++)
    {
        if (src[i] != dest[i]) {
            printf("src[%d] %c dest[%d] %c\n", i, src[i], i, dest[i]);
            diff++;
        }
    }

    if (diff) {
        printf("%d diffs\n", diff);
        return diff;
    } else {
        printf("src is same as dest\n", diff);
        return 0;
    }
}

int write_file(char *a, int len, int fd)
{
	int r = write(fd, a, len);	
	printf("write sucess: %d\n",r);
}

int read_file(char *buf, int len, int fd)
{
    lseek(fd, 0, SEEK_SET);
   int r = read(fd, buf, len); 
	printf("read sucess: %d\n",r);
}


int main(int argc, char **argv)
{
    char command = ' ';
	if (argc < 3)
	{
	    printf("Lack of argument:\n");	
	    printf("%s file num A/B\n", argv[0]);	
        return -1;
	}
    char *file = argv[1]; 
    num = atoi(argv[2]);
	char chars = *argv[3];

	printf("file is %s num is %d chars is %c\n", file, num, chars);

    fill_buf(buf, chars, num);
    
    if ((fd = open(file, O_RDWR | O_CREAT)) == -1)
    {
        printf("can open file %s\n", file);
        return -1;
    }

    write_file(buf, num, fd);
    printf("please input comand 'r' to read from %s\n", file);
   
    while ( (command=getchar()) != 'r' ) {
        printf("input 'r' please!");
    }

    printf("command %c right, start read ...\n", command);
    read_file(read_buf, num, fd);
    
    compare_buf(buf, read_buf, num);
}
