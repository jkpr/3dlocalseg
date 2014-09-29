/*
gcc -Wall -Iinc -o bin/mat_ops src/matrix_ops.c src/unit_tests.c src/matrix_main.c
*/

#include "unit_tests.h"
#include "matrix_ops.h"

int main()
{
    unit_tests();

    return 0;
}