#include <stdio.h>

int main() {
    int count, i, num, sum = 0;
    
    printf("How many numbers do you want to add? ");
    scanf("%d", &count);
    
    for(i = 0; i < count; i++) {
        printf("Enter number %d: ", i + 1);
        scanf("%d", &num);
        sum += num;
    }
    
    printf("Sum is: %d\n", sum);
    return 0;
}