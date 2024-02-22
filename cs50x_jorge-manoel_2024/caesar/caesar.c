#include <cs50.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, string argv[])
{
    if (argc == 2)
    {
        int is_number =  0;
        for (int i = 0; i < strlen(argv[1]); i++)
        {
            if (isdigit(argv[1][i]))
            {
                is_number++;
            }
        }

        if  (is_number == strlen(argv[1]))
        {
            string word = get_string("plaintext: ");
            for (int j = 0; j < strlen(word); j++)
            {
                if (isalpha(word[j]))
                {
                    if (isupper(word[j]))
                    {
                        char w = word[j] - 'A';
                        int caesar_code = atoi(argv[1]);
                        word[j] = (w + caesar_code)%26 + 'A';
                    }
                    else if (islower(word[j]))
                    {
                        char w = word[j] - 'a';
                        int caesar_code = atoi(argv[1]);
                        word[j] = (w + caesar_code)%26 + 'a';
                    }
                }
            }
            printf("ciphertext: %s\n", word);
        }
        else
        {
            printf("Usage: %s key\n", argv[0]);
            return 1;
        }

    }

    else
    {
        printf("Usage: %s key\n", argv[0]);
        return 1;
    }

}
