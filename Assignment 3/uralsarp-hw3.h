#ifndef __HW3_H
#define __HW3_H

#include <stdio.h>
#include <stdbool.h>


typedef struct generalNode
{
    int type; //integer, real num or string. 1=int 2=real 3=string
    int lineNumber;
    double realVal;
    int intVal;
    char *strVal;
    bool mismatch;
    bool constantexp;
    bool toplevel;
    bool mismatchTop;

} generalNode;



#endif