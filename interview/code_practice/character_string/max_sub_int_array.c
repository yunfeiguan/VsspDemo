#include<stdio.h>
#include<stdlib.h>
#include<string.h>

int sub_array(int *array, int pos, int len) 
{
    int sum = 0, i = 0;

    for (i = 0; i < len; i++)
        sum += array[pos + i];

    printf("postion is %d len is %d value is %d\n", pos, len, sum);
    return sum;
}

int get_max_value(int *pos, int *num, int *array, int len)
{
    int i = 0, j = 0;
    int max_value = 0, value = 0;
    
    max_value = sub_array(array, 0, len);
    *pos = 0;
    *num = len;

    for (i = len - 1; i > 0; i--) { //length 从1-9
        printf("its %d rond\n", i);
        for (j = 0; j <= len - i; j++) { //position 最小是0， 最大是9
            value = sub_array(array, j, i);

            if (value > max_value) {
                max_value = value;
                *pos = j;
                *num = i;
                printf("max value is %d pos is %d num is %d\n",
                        max_value, j, i);
            }
        }
    }

    return max_value;
}

int main()
{
    int pos = 0, num = 0, max_value = 0;
    int my_array[10] = {-5,-2,-1,4,9,8,-4,-9,20,0};

    //max_value = get_max_value(&pos, &num, my_array, 10);

    max_value = 0x80000000;

    printf("the max value is %d position is %d num is %d\n",
            max_value, pos, num);

    return 0;
}
