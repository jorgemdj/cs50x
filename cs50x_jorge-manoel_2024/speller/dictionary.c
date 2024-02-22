// Implements a dictionary's functionality

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>

#include "dictionary.h"

// Represents a node in a hash table
typedef struct node
{
    char word[LENGTH + 1];
    struct node *next;
} node;

int COUNT = 0;

// TODO: Choose number of buckets in hash table
const unsigned int N = 26;

// Hash table
node *table[N];

// Returns true if word is in dictionary, else false
bool check(const char *word)
{
    int len = strlen(word);
    char word_check[len + 1];
    strcpy(word_check, word);

    for (int i = 0; i < len; i++)
    {
        word_check[i] = tolower(word_check[i]);
    }

    node *dict_word = table[hash(word_check)];

    while (dict_word != NULL)
    {
        if (strcmp(dict_word->word, word_check) == 0)
        {
            return true;
        }
        dict_word = dict_word->next;
    }
    return false;
}

// Hashes word to a number
unsigned int hash(const char *word)
{
    return toupper(word[0]) - 'A';
}

// Loads dictionary into memory, returning true if successful, else false
bool load(const char *dictionary)
{
    FILE *dict = fopen(dictionary, "r");
    node *buffer = malloc(sizeof(node));
    if (buffer == NULL)
    {
        return false;
    }
    if (dict != NULL)
    {
        while (!(fscanf(dict, "%s", buffer->word) == EOF))
        {
            COUNT++;
            node *new_node = malloc(sizeof(node));
            if (new_node == NULL)
            {
                free(new_node);
                return false;
            }
            if (table[hash(buffer->word)] == NULL)
            {
                strcpy(new_node->word, buffer->word);
                new_node->next = NULL;
                table[hash(new_node->word)] = new_node;
            }
            else
            {
                strcpy(new_node->word, buffer->word);
                new_node->next = table[hash(new_node->word)];
                table[hash(new_node->word)] = new_node;
            }
        }
        free(buffer);
        fclose(dict);
        return true;
    }
    else
    {
        free(buffer);
        return false;
    }
}

// Returns number of words in dictionary if loaded, else 0 if not yet loaded
unsigned int size()
{
    return COUNT;
}

// Unloads dictionary from memory, returning true if successful, else false
bool unload(void)
{
    node *cursor;
    node *tmp;

    for (int i = 0; i < N; i++)
    {
        cursor = table[i];
        tmp = table[i];
        while (tmp != NULL)
        {
            cursor = cursor->next;
            free(tmp);
            tmp = cursor;
        }
    }
    return true;
}
