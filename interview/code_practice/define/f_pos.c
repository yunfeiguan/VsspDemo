#include<stdio.h>

#define FPOS( type, field ) \
    (int)(&(((type *) 0)->field))

/*#define FPOS( type, field ) \
    ((int) &(( type *) 0)->field )*/

#define ADDR(type, field_addr, filed) \
    (unsigned long)(&(field_addr)) - (int)(&(((type *) 0)->filed))


typedef struct my_struct_ {
    char a;
    char b;
    int age;
    char name[100];
} my_struct;

int main()
{
    my_struct a;
    a.a = 'a';
    a.b = 'b';
    a.age = 30;

    printf("my_struct has %d bytes, a offset %d b offset %d  \
            age offset %d\n", sizeof(a), FPOS(my_struct, a), \
            FPOS(my_struct, b), FPOS(my_struct, age));

    printf("a address is %u  ADDR is %u %lu %lu %lu\n", &a, 
            ADDR(my_struct, a.age, age),
            ADDR(my_struct, a.a, a),
            ADDR(my_struct, a.b, b),
            ADDR(my_struct, a.name, name));
    return 0;
}
