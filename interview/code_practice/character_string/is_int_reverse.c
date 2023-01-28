#include<stdio.h>
#include<stdlib.h>
#include<string.h>

int if_reverse_str(char *str, int length)
{
    int i = 0;
    int mid = length/2;
    
    for (i = 0; i < mid; i++) {
        if (*(str+i) != *(str + length -i - 1))
            return 0;
    }

    return 1;
}


int main()
{
    int input_num = 0;
    char str[10] = {'\0'};

    scanf("%d", &input_num);

    //itoa(input_num, str, 10);
    sprintf(str, "%d", input_num);

    if (if_reverse_str(str, strlen(str)))
        printf("input number %d is reverse!\n", input_num);
    else
        printf("input number %d is not reverse!\n", input_num);
    return 0;
}


