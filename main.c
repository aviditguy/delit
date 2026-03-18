#include <stdio.h>
#include <string.h>

void printSubsequence(char *str, char *temp, int i, int j)
{
    if (str[i] == '\0')  // string end
    {
        temp[j] = '\0';
        if (j > 0)  // skip empty string
            printf("%s\n", temp);
        return;
    }

    // include str[i]
    temp[j] = str[i];
    printSubsequence(str, temp, i + 1, j + 1);

    // exclude str[i]
    printSubsequence(str, temp, i + 1, j);
}

int main()
{
    char str[] = "ABC";
    char temp[100];

    printSubsequence(str, temp, 0, 0);

    return 0;
}
