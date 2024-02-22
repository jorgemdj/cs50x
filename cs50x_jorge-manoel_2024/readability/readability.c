#include <cs50.h>
#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <string.h>


int main(void)
{
    // receber texto
    string text = get_string("Text: ");

    float cont_words = 1;
    float cont_sentences = 0;
    float cont_letters = 0;

    for (int i = 0; i < strlen(text); i++)
    {
        if (text[i] == ' ')
        {
            cont_words++;
        }
        else if (text[i] == '.' || text[i] == '!' || text[i] == '?')
        {
            cont_sentences++;
        }
        else if (isalpha(text[i]))
        {
            cont_letters++;
        }
    }

    float L = cont_letters * 100 / cont_words;
    float S = cont_sentences * 100 / cont_words;

    float index = 0.0588 * L - 0.296 * S - 15.8;
    int result = round(index);

    if (index < 1)
    {
        printf("Before Grade 1\n");
    }
    else if (index > 16)
    {
        printf("Grade 16+\n");
    }
    else
    {
        printf("Grade %i\n", result);
    }

}

