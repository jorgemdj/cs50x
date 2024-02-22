#include <cs50.h>
#include <ctype.h>
#include <string.h>
#include <stdio.h>


int points[] = {1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10};

int letter_points(string word);

int main(void)
{
    string word_1 = get_string("Player 1: ");
    int score_1 = letter_points(word_1);
    //printf("%i\n", score_1);

    string word_2 = get_string("Player 2: ");
    int score_2 = letter_points(word_2);
    //printf("%i\n", score_2);

    if (score_1 > score_2)
    {
        printf("Player 1 wins!\n");
    }
    else if (score_1 < score_2)
    {
        printf("Player 2 wins!\n");
    }
    else
    {
        printf("Tie!\n");
    }

}

int letter_points(string word)
{
    int score = 0;
    for (int c = 0; c < strlen(word); c++)
    {
        if (isalpha(word[c]))
        {
            char i = 'a';
            int l = tolower(word[c]) - i;
            score += points[l];
            //printf("%i\n", score);
        }
    }
    return (score);
}
