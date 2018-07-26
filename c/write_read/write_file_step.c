#include<stdio.h>
#include<fcntl.h>
#include<unistd.h>
#include<sys/types.h>
#include<sys/stat.h>
#include<error.h>
#include<string.h>

int fd = 0;
char buf[131073]={0};
char read_buf[131073]={0};
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

int write_file(char *a, int len, int fd, unsigned long off)
{
	int r = pwrite(fd, a, len, off);	
	printf("write sucess: offset %d %d %c\n", off, r, a[0]);
}

int read_file(char *buf, int len, int fd, unsigned long off)
{
    //lseek(fd, 0, SEEK_SET);
    //int r = read(fd, buf, len); 
    //int r = pread(fd, buf, len);
    int r = pread(fd, buf, len, off);
	printf("read sucess: %d %c\n",r, buf[0]);
}


int main(int argc, char **argv)
{
    char command = ' ';
    unsigned long offset = 0;
	
    if (argc < 3)
	{
	    printf("Lack of argument:\n");	
	    printf("%s file num A/B\n", argv[0]);	
        return -1;
	}
    char *file = argv[1]; 
    num = atoi(argv[2]);
    char chars = *argv[3];

	printf("file is %s num is %d \n", file, num);
    
    if ((fd = open(file, O_RDWR | O_CREAT)) == -1)
    {
        printf("can open file %s\n", file);
        return -1;
    }
    
    printf("please input comand 'n' or 'w' \n \
            'n': offset will add num afeter write\n \
            'w/any letter': write at offset don't change offset\n");
    
    command = getchar();
    while (command != 'q') {
        getchar();
        char letter = command;
        printf("command is : %c\n", command);
        fill_buf(buf, letter, num);
        write_file(buf, num, fd, offset);
        
        if (command == 'r') {
            printf("will write at same offset: %d\n", offset);    
        } else if (command == 'n') {
            offset += num;
            printf("will write at next offset: %d\n", offset);    
        }
        command = getchar();
    }

    printf("command %c not right, exit ...\n", command);
}
