#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int main(int argc, char *argv[])
{
    if (argc == 1 || argc > 2)
    {
        printf("Usage: ./recover input.raw\n");
        return 1;
    }

    FILE * memory_recover = fopen(argv[1], "r");
    if (memory_recover == NULL)
    {
        printf("Could not open file.\n");
        return 1;
    }

    uint8_t buffer[512];
    int count = 0;
    FILE * backup = NULL;
    char filename[8];

    while (fread(buffer, sizeof(buffer[0]), 512, memory_recover))
    {
        if (buffer[0] == 0xff && buffer[1] == 0xd8 && buffer[2] == 0xff && (buffer[3] & 0xf0) == 0xe0)
        {
            if (backup != NULL)
            {
                fclose(backup);
            }
            sprintf(filename, "%03i.jpg", count);
            backup = fopen(filename, "w");
            count++;
        }
        if (backup != NULL)
        {
            fwrite(buffer, sizeof(buffer[0]), 512, backup);
        }
    }
    fclose(memory_recover);
    fclose(backup);
}
