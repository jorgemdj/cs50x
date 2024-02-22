#include <cs50.h>
#include <stdio.h>

int validate(long card);

long c_number = -1;
int soma = 0;
int i = 1;

int main(void)
{
    while (c_number < 0)
    {
        c_number = get_long("Number: ");
    }

    if (validate(c_number) == 0)
    {
        int id = c_number / 1000000000000;
        if (id / 100 > 50 && id / 100 < 56)
        {
            printf("MASTERCARD\n");
        }
        else if (id / 10 == 34 || id / 10 == 37)
        {
            printf("AMEX\n");
        }
        else if (id / 1000 == 4 || id == 4)
        {
            printf("VISA\n");
        }
        else
        {
            printf("INVALID\n");
        }
    }
    else
    {
        printf("INVALID\n");
    }
}

int validate(long card)
{
    while (card > 0)
    {
        int digit = card % 10;

        if (i % 2 == 0)
        {
            digit = digit * 2;
            if (digit > 9)
            {
                digit = digit / 10 + digit % 10;
            }
        }
        soma += digit;
        card = card / 10;
        i++;
    }
    return soma%10;
}
