#include <cs50.h>
#include <stdio.h>

void ladoa(int a, int z);
void ladob(int b, int z);
int n;

int main(void)
{

    while (n < 1)
    {
        n = get_int("Height: ");
    }

    for (int i = 0; i < n; i++)
    {
        ladoa(n, i);
        printf("  ");
        ladob(n, i);
    }
}

void ladoa(int a, int z)
{
    for (int j = 0; j < a - z - 1; j++)
    {
        printf(" ");
    }
    for (int j = 0; j <= z; j++)
    {
        printf("#");
    }
}

void ladob(int b, int w)
{
    for (int j = 0; j <= w; j++)
    {
        printf("#");
    }
    printf("\n");
}
