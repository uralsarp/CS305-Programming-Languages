
%{
	#include <stdio.h>
	void yyerror(const char *s)
	{
 
	}
%}


%token tSTRING tNUM tPRINT tGET tSET tFUNCTION tRETURN tIDENT tIF tEQUALITY tGT tLT tGEQ tLEQ tADD tSUB tMUL tDIV tINC tDEC
%start algorithm



%%

algorithm:  '[' statements ']'
       | '[' ']'
;

statement:  set
	  | if
	  | print
	  | increment
	  | decrement
	  | return
	  | expression
;

statements:  statement
	   | statement statements
;

expression:  tNUM
	   | tSTRING
	   | get
	   | function_dec
	   | operator_app
	   | condition
;

set:  '[' tSET ',' tIDENT ',' expression ']'
;

if:  '[' tIF ',' condition ',' w_else ']'
   | '[' tIF ',' condition ',' wo_else ']'
;

wo_else:  '[' statements ']'  
	| '[' ']'
;

w_else:  '[' statements ']' '[' statements ']'
       | '[' ']' '[' ']'
       | '[' statements ']' '[' ']'
       | '[' ']' '[' statements ']'
; 

print:  '[' tPRINT ',' expression ']'
      | '[' tPRINT ',' '[' expression ']' ']'
;

increment: '[' tINC ',' tIDENT ']'
;

decrement: '[' tDEC ',' tIDENT ']'
;

condition:  '[' tLEQ ',' expression ',' expression ']'
	  | '[' tGEQ ',' expression ',' expression ']'
	  | '[' tEQUALITY ',' expression ',' expression ']'
	  | '[' tGT ',' expression ',' expression ']'
	  | '[' tLT ',' expression ',' expression ']'
;

get:  '[' tGET ',' tIDENT ']'
    | '[' tGET ',' tIDENT ',' '[' ']' ']'
    | '[' tGET ',' tIDENT ',' '[' expressions ']' ']'
;

expressions:  expression
	    | expression ',' expressions
;

function_dec:  '[' tFUNCTION ',' '[' parameters ']' ',' '[' statements ']' ']'
             | '[' tFUNCTION ',' '[' ']' ',' '[' statements ']' ']'
	     | '[' tFUNCTION ',' '[' parameters ']' ',' '[' ']' ']'
             | '[' tFUNCTION ',' '[' ']' ',' '[' ']' ']'   
;

parameters:  tIDENT
	   | tIDENT ',' parameters
;

operator_app:  '[' tADD ',' expression ',' expression ']'
	     | '[' tSUB ',' expression ',' expression ']'
	     | '[' tMUL ',' expression ',' expression ']'
	     | '[' tDIV ',' expression ',' expression ']'
;

return:   '[' tRETURN ']'
	| '[' tRETURN ',' expression ']' 
;

%%

int main ()
{
	if (yyparse())
	{
	 // parse error
	 printf("ERROR\n");
	 return 1;
	}
	else
	{
	 // successful parsing
	 printf("OK\n");
	 return 0;
	}
}
