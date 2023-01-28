#include<stdio.h>

int reverse(int num)
{
    unsigned int sum = 0, val = 0;
    char flag = 0;
    if (num < 0) {
        num = 0 - num;
        flag = 1;
    }

    while (num) {
        val = num % 10;
        sum = sum*10 + val;
        num = num / 10;
    }

    if (sum > 0x0FFFFFFe) {
        return 0;
    } else {
        if (flag)
            return (int)(-1 * sum);
    }

    return (int)sum;
}

int main()
{
    int a;

    while (1) {
        scanf("%d", &a);
        printf("input num is %d\n", a);

        a = reverse(a);

        printf("output is %d\n", a);
    }

}
