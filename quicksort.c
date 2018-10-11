#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

void swap(char** a, char**b){ 
    char* temp = *a; 
    *a = *b; 
    *b = temp; 
} 

char minuscula(char may){
    if (may>90||may<65){
        return may;
    }
    return (may + 32);
}


int mi_atoi(char* str){
    int i = 0;
    bool neg = false;
    if(str[i] == '-'){
        i+=1;
        neg = true;
    }
    int result = 0;
    while((str[i]!='\0') && (str[i]!='\n')){
        result*=10;
        int val = (int) str[i] - 48;
        if (neg){
            result-=val;
        }
        else{
            result+=val;
        }
        i+=1;
    }
    return result;
}

int cmp_int(int a, int b){
    if (b>a){
        return 1;
    }
    return 0;
}

int cmp_alf(char*a, char*b){
    int i = 0;
    int cmp = 0;
    bool fin = false;
    while (!fin){
        if ((b[i]=='\0') || (minuscula(b[i]) < minuscula(a[i]))){
            fin=true;
            cmp = 0;
        }
        else if((a[i] == '\0') || (minuscula(a[i]) < minuscula(b[i]))){
            fin = true;
            cmp = 1;
        }
        i+=1;
    }
    return cmp;
}
  
char** partition (char** a,char**b, int num){ 
    char*pivot = b[0];
    int pivot_int;
    int i = -1;
    int cmp = 0;
    if (num!=0){
        pivot_int = mi_atoi(b[0]);
    }
    for (int j = 0; &a[j]!=b ; j++) {

        if (num!=0){
            cmp = cmp_int(pivot_int,mi_atoi(a[j]));
        }
        else {
            cmp = cmp_alf(pivot,a[j]);
        }
        
        if (cmp==0){ 
            i++; 
            swap (&a[i], &a[j]); 
        } 
    } 
    swap (&a[i + 1], b); 
    return (&a[i+1]); 
} 
  

void quicksort(char** a, char** b, int num){ 
    if (a>b){
        return;
    }
    char** p = partition(a,b,num);  
    quicksort(a,p-1,num);  
    quicksort(p+1,b,num);  
} 
