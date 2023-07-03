%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "uralsarp-hw3.h"
void yyerror (const char *s) 
{}

extern int numLine;
typedef struct printNode {
		generalNode * generalNodePtr;
		struct printNode * next;
} printNode;

printNode * head = NULL;

void insertPtr(generalNode *);
void printPtr(printNode *);
%}


%union {
	int lineNum;
	double realValue;
    int intValue;
    char *strValue;
	generalNode * generalNodePtr;
}



%token tPRINT tGET tSET tFUNCTION tRETURN tIDENT tEQUALITY tIF tGT tLT tGEQ tLEQ tINC tDEC
%token <lineNum> tMUL
%token <lineNum> tSUB
%token <lineNum> tADD
%token <lineNum> tDIV
%token <strValue> tSTRING
%token <realValue> tREAL
%token <intValue> tINT


%type <generalNodePtr> expr
%type <generalNodePtr> operation
%type <generalNodePtr> if
%type <generalNodePtr> print
%type <generalNodePtr> returnStmt
%type <generalNodePtr> getExpr
%type <generalNodePtr> function
%type <generalNodePtr> exprList
%type <generalNodePtr> setStmt
%type <generalNodePtr> condition



%start prog

%%
prog:		'[' stmtlst ']'
;

stmtlst:	stmtlst stmt |
;

stmt:		setStmt {insertPtr($1);}
| if {insertPtr($1);}
| print {insertPtr($1);}
| unaryOperation 
| expr {insertPtr($1);}
| returnStmt {insertPtr($1);}
;

getExpr:	'[' tGET ',' tIDENT ',' '[' exprList ']' ']'{
	$$ = (generalNode*)malloc(sizeof(generalNode));
	$$->constantexp=false;
	$$->mismatch=false;
	$$->type=$7->type;
}
| '[' tGET ',' tIDENT ',' '[' ']' ']'{
	$$ = (generalNode*)malloc(sizeof(generalNode));
	$$->constantexp=false;
	$$->mismatch=false;
}
| '[' tGET ',' tIDENT ']'{
	$$ = (generalNode*)malloc(sizeof(generalNode));
	$$->constantexp=false;
	$$->mismatch=false;
}
;

setStmt:	'[' tSET ',' tIDENT ',' expr ']' {
	$$ = (generalNode*)malloc(sizeof(generalNode));
	$$->lineNumber=numLine;
	$$->constantexp=$6->constantexp;
	$$->mismatch=$6->mismatch;
	$$->type=$6->type;
	if($6->type==1){
		$$->intVal=$6->intVal;
	}
	else if($6->type==2){
		$$->realVal=$6->realVal;
	}
	else if($6->type==3){
		$$->strVal=$6->strVal;
	}
	
}
;

if:		'[' tIF ',' condition ',' '[' stmtlst ']' ']'{
		$$ = (generalNode*)malloc(sizeof(generalNode));
		$$->constantexp=false;
		$$->mismatch=false;
}
		| '[' tIF ',' condition ',' '[' stmtlst ']' '[' stmtlst ']' ']' {
		$$ = (generalNode*)malloc(sizeof(generalNode));
		$$->constantexp=false;
		$$->mismatch=false;
	}
;

print:		'[' tPRINT ',' expr ']'{
	$$ = (generalNode*)malloc(sizeof(generalNode));
	$$->constantexp=$4->constantexp;
    $$->mismatch=$4->mismatch;
	if($4->type==1){
		$$->intVal=$4->intVal;
	}
	else if($4->type==2){
		$$->realVal=$4->realVal;
	}
	else if($4->type==3){
		$$->strVal=$4->strVal;
	}
}
;

operation:	'[' tADD ',' expr ',' expr ']' {
	$$ = (generalNode*)malloc(sizeof(generalNode));
	$$->lineNumber=$2;
		if ($4->type==1 && $6->type==1){ //int + int
			$$->type=1;
			$$->intVal=$4->intVal + $6->intVal;
			$$->mismatch=false;
			$$->constantexp=true;
			$$->toplevel=true;
		}
		else if($4->type==2 && $6->type==2){ //real num + real num
			$$->type=2;
			$$->realVal=$4->realVal + $6->realVal;
			$$->mismatch=false;
			$$->constantexp=true;
			$$->toplevel=true;
		}
		else if($4->type==3 && $6->type==3){ //string concat
			$$->type=3;
			char * concatstr = (char*) malloc(1 + strlen($4->strVal) + strlen($6->strVal));
			strcpy(concatstr, $4->strVal);
			strcat(concatstr, $6->strVal);
			$$->strVal = concatstr;
			$$->mismatch=false;
			$$->constantexp=true;
			$$->toplevel=true;
		}
		else if($4->type==1 && $6->type==2){ // int + real -> value real
			$$->type=2;
			$$->realVal=$4->intVal + $6->realVal;
			$$->mismatch=false;
			$$->constantexp=true;
			$$->toplevel=true;
		}
		else if($4->type==2 && $6->type==1){ //real + int -> value real
			$$->type=2;
			$$->realVal=$4->realVal + $6->intVal;
			$$->mismatch=false;
			$$->constantexp=true;
			$$->toplevel=true;
		}
		else if($4->type==1 && $6->type==3){ //int + string -> invalid
			$$->mismatch=true;
			$$->constantexp=false;		
			if ($4->toplevel==true){
			    $$->constantexp=false;	
				if($4->type==1){
					$$->type=1;
					$$->intVal=$4->intVal;
					$$->mismatchTop=true;
				}
				else if($4->type==2){
					$$->type=2;
					$$->realVal=$4->realVal;
					$$->mismatchTop=true;
				}
				else if($4->type==3){
					$$->type=3;
					$$->strVal=$4->strVal;
					$$->mismatchTop=true;
				}
			}
			else if($6->toplevel==true){
				$$->constantexp=false;	
				if($6->type==1){
					$$->type=1;
					$$->intVal=$6->intVal;
					$$->mismatchTop=true;
				}
				else if($6->type==2){
					$$->type=2;
					$$->realVal=$6->realVal;
					$$->mismatchTop=true;
				}
				else if($6->type==3){
					$$->type=3;
					$$->strVal=$6->strVal;
					$$->mismatchTop=true;
				}
			}
			
		}
		else if($4->type==2 && $6->type==3){ //real + string -> invalid
			$$->mismatch=true;
			$$->constantexp=false;		
			if ($4->toplevel==true){
			    $$->constantexp=false;	
				if($4->type==1){
					$$->type=1;
					$$->intVal=$4->intVal;
					$$->mismatchTop=true;
				}
				else if($4->type==2){
					$$->type=2;
					$$->realVal=$4->realVal;
					$$->mismatchTop=true;
				}
				else if($4->type==3){
					$$->type=3;
					$$->strVal=$4->strVal;
					$$->mismatchTop=true;
				}
			}
			else if($6->toplevel==true){
				$$->constantexp=false;	
				if($6->type==1){
					$$->type=1;
					$$->intVal=$6->intVal;
					$$->mismatchTop=true;
				}
				else if($6->type==2){
					$$->type=2;
					$$->realVal=$6->realVal;
					$$->mismatchTop=true;
				}
				else if($6->type==3){
					$$->type=3;
					$$->strVal=$6->strVal;
					$$->mismatchTop=true;
				}
			}
			
		}
		else if($4->type==3 && $6->type==1){ //string + int -> invalid
			$$->mismatch=true;
			$$->constantexp=false;		
			if ($4->toplevel==true){
			    $$->constantexp=false;	
				if($4->type==1){
					$$->type=1;
					$$->intVal=$4->intVal;
					$$->mismatchTop=true;
				}
				else if($4->type==2){
					$$->type=2;
					$$->realVal=$4->realVal;
					$$->mismatchTop=true;
				}
				else if($4->type==3){
					$$->type=3;
					$$->strVal=$4->strVal;
					$$->mismatchTop=true;
				}
			}
			else if($6->toplevel==true){
				$$->constantexp=false;	
				if($6->type==1){
					$$->type=1;
					$$->intVal=$6->intVal;
					$$->mismatchTop=true;
				}
				else if($6->type==2){
					$$->type=2;
					$$->realVal=$6->realVal;
					$$->mismatchTop=true;
				}
				else if($6->type==3){
					$$->type=3;
					$$->strVal=$6->strVal;
					$$->mismatchTop=true;
				}
			}
		}
		else if($4->type==3 && $6->type==2){ //string + real -> invalid
			$$->mismatch=true;
			$$->constantexp=false;		
			if ($4->toplevel==true){
			    $$->constantexp=false;	
				if($4->type==1){
					$$->type=1;
					$$->intVal=$4->intVal;
					$$->mismatchTop=true;
				}
				else if($4->type==2){
					$$->type=2;
					$$->realVal=$4->realVal;
					$$->mismatchTop=true;
				}
				else if($4->type==3){
					$$->type=3;
					$$->strVal=$4->strVal;
					$$->mismatchTop=true;
				}
			}
			else if($6->toplevel==true){
				$$->constantexp=false;	
				if($6->type==1){
					$$->type=1;
					$$->intVal=$6->intVal;
					$$->mismatchTop=true;
				}
				else if($6->type==2){
					$$->type=2;
					$$->realVal=$6->realVal;
					$$->mismatchTop=true;
				}
				else if($6->type==3){
					$$->type=3;
					$$->strVal=$6->strVal;
					$$->mismatchTop=true;
				}
			}
		}
		else{
			$$->constantexp=false;
			if($4->mismatch==true || $6->mismatch==true){
				$$->mismatch = true;
				if($4->mismatch==true){
					insertPtr($4);
				}
			}
			else if($4->toplevel==true || $6->toplevel==true){
				$$->toplevel=true;
				if ($4->toplevel==true){
					$$->constantexp=false;	
					if($4->type==1){
						$$->type=1;
						$$->intVal=$4->intVal;
					}
					else if($4->type==2){
						$$->type=2;
						$$->realVal=$4->realVal;
					}
					else if($4->type==3){
						$$->type=3;
						$$->strVal=$4->strVal;
					}
				}
				else if($6->toplevel==true){
					$$->constantexp=false;	
					if($6->type==1){
						$$->type=1;
						$$->intVal=$6->intVal;
					}
					else if($6->type==2){
						$$->type=2;
						$$->realVal=$6->realVal;
					}
					else if($6->type==3){
						$$->type=3;
						$$->strVal=$6->strVal;
					}
				}
			}
			

		}

}
		| '[' tSUB ',' expr ',' expr ']' {
			$$ = (generalNode*)malloc(sizeof(generalNode));
			$$->lineNumber=$2;
			if ($4->type==1 && $6->type==1){ //int - int
				$$->type=1;
				$$->intVal=$4->intVal - $6->intVal;
				$$->mismatch=false;
				$$->constantexp=true;
				$$->toplevel=true;
			}
			else if($4->type==2 && $6->type==2){ //real num - real num
				$$->type=2;
				$$->realVal=$4->realVal - $6->realVal;
				$$->mismatch=false;
				$$->constantexp=true;
				$$->toplevel=true;
			}
			else if($4->type==3 && $6->type==3){ //both string
				$$->mismatch=true;
				$$->constantexp=false;		
				if ($4->toplevel==true){
					$$->constantexp=false;	
					if($4->type==1){
						$$->type=1;
						$$->intVal=$4->intVal;
						$$->mismatchTop=true;
					}
					else if($4->type==2){
						$$->type=2;
						$$->realVal=$4->realVal;
						$$->mismatchTop=true;
					}
					else if($4->type==3){
						$$->type=3;
						$$->strVal=$4->strVal;
						$$->mismatchTop=true;
					}
				}
				else if($6->toplevel==true){
					$$->constantexp=false;	
					if($6->type==1){
						$$->type=1;
						$$->intVal=$6->intVal;
						$$->mismatchTop=true;
					}
					else if($6->type==2){
						$$->type=2;
						$$->realVal=$6->realVal;
						$$->mismatchTop=true;
					}
					else if($6->type==3){
						$$->type=3;
						$$->strVal=$6->strVal;
						$$->mismatchTop=true;
					}
				}
			}
			else if($4->type==1 && $6->type==2){ // int - real -> value real
				$$->type=2;
				$$->realVal=$4->intVal - $6->realVal;
				$$->mismatch=false;
				$$->constantexp=true;
				$$->toplevel=true;
			}
			else if($4->type==2 && $6->type==1){ //real - int -> value real
				$$->type=2;
				$$->realVal=$4->realVal - $6->intVal;
				$$->mismatch=false;
				$$->constantexp=true;
				$$->toplevel=true;
			}
			else if($4->type==1 && $6->type==3){ //int - string -> invalid
				$$->mismatch=true;
				$$->constantexp=false;		
				if ($4->toplevel==true){
					$$->constantexp=false;	
					if($4->type==1){
						$$->type=1;
						$$->intVal=$4->intVal;
						$$->mismatchTop=true;
					}
					else if($4->type==2){
						$$->type=2;
						$$->realVal=$4->realVal;
						$$->mismatchTop=true;
					}
					else if($4->type==3){
						$$->type=3;
						$$->strVal=$4->strVal;
						$$->mismatchTop=true;
					}
				}
				else if($6->toplevel==true){
					$$->constantexp=false;	
					if($6->type==1){
						$$->type=1;
						$$->intVal=$6->intVal;
						$$->mismatchTop=true;
					}
					else if($6->type==2){
						$$->type=2;
						$$->realVal=$6->realVal;
						$$->mismatchTop=true;
					}
					else if($6->type==3){
						$$->type=3;
						$$->strVal=$6->strVal;
						$$->mismatchTop=true;
					}
				}
			}
			else if($4->type==2 && $6->type==3){ //real - string -> invalid
				$$->mismatch=true;
				$$->constantexp=false;		
				if ($4->toplevel==true){
					$$->constantexp=false;	
					if($4->type==1){
						$$->type=1;
						$$->intVal=$4->intVal;
						$$->mismatchTop=true;
					}
					else if($4->type==2){
						$$->type=2;
						$$->realVal=$4->realVal;
						$$->mismatchTop=true;
					}
					else if($4->type==3){
						$$->type=3;
						$$->strVal=$4->strVal;
						$$->mismatchTop=true;
					}
				}
				else if($6->toplevel==true){
					$$->constantexp=false;	
					if($6->type==1){
						$$->type=1;
						$$->intVal=$6->intVal;
						$$->mismatchTop=true;
					}
					else if($6->type==2){
						$$->type=2;
						$$->realVal=$6->realVal;
						$$->mismatchTop=true;
					}
					else if($6->type==3){
						$$->type=3;
						$$->strVal=$6->strVal;
						$$->mismatchTop=true;
					}
				}
			}
			else if($4->type==3 && $6->type==1){ //string - int -> invalid
				$$->mismatch=true;
				$$->constantexp=false;		
				if ($4->toplevel==true){
					$$->constantexp=false;	
					if($4->type==1){
						$$->type=1;
						$$->intVal=$4->intVal;
						$$->mismatchTop=true;
					}
					else if($4->type==2){
						$$->type=2;
						$$->realVal=$4->realVal;
						$$->mismatchTop=true;
					}
					else if($4->type==3){
						$$->type=3;
						$$->strVal=$4->strVal;
						$$->mismatchTop=true;
					}
				}
				else if($6->toplevel==true){
					$$->constantexp=false;	
					if($6->type==1){
						$$->type=1;
						$$->intVal=$6->intVal;
						$$->mismatchTop=true;
					}
					else if($6->type==2){
						$$->type=2;
						$$->realVal=$6->realVal;
						$$->mismatchTop=true;
					}
					else if($6->type==3){
						$$->type=3;
						$$->strVal=$6->strVal;
						$$->mismatchTop=true;
					}
				}
			}
			else if($4->type==3 && $6->type==2){ //string - real -> invalid
				$$->mismatch=true;
				$$->constantexp=false;		
				if ($4->toplevel==true){
					$$->constantexp=false;	
					if($4->type==1){
						$$->type=1;
						$$->intVal=$4->intVal;
						$$->mismatchTop=true;
					}
					else if($4->type==2){
						$$->type=2;
						$$->realVal=$4->realVal;
						$$->mismatchTop=true;
					}
					else if($4->type==3){
						$$->type=3;
						$$->strVal=$4->strVal;
						$$->mismatchTop=true;
					}
				}
				else if($6->toplevel==true){
					$$->constantexp=false;	
					if($6->type==1){
						$$->type=1;
						$$->intVal=$6->intVal;
						$$->mismatchTop=true;
					}
					else if($6->type==2){
						$$->type=2;
						$$->realVal=$6->realVal;
						$$->mismatchTop=true;
					}
					else if($6->type==3){
						$$->type=3;
						$$->strVal=$6->strVal;
						$$->mismatchTop=true;
					}
				}
			}
			else{
				if($4->mismatch==true || $6->mismatch==true){
					$$->mismatch = true;
					if($4->mismatch==true){
						insertPtr($4);
					}
				}	
				else if($4->toplevel==true || $6->toplevel==true){
					$$->toplevel=true;
					if ($4->toplevel==true){
						$$->constantexp=false;	
						if($4->type==1){
							$$->type=1;
							$$->intVal=$4->intVal;
						}
						else if($4->type==2){
							$$->type=2;
							$$->realVal=$4->realVal;
						}
						else if($4->type==3){
							$$->type=3;
							$$->strVal=$4->strVal;
						}
					}
					else if($6->toplevel==true){
						$$->constantexp=false;	
						if($6->type==1){
							$$->type=1;
							$$->intVal=$6->intVal;
						}
						else if($6->type==2){
							$$->type=2;
							$$->realVal=$6->realVal;
						}
						else if($6->type==3){
							$$->type=3;
							$$->strVal=$6->strVal;
						}
					}
				}
			}
		}

		| '[' tMUL ',' expr ',' expr ']'{
			$$ = (generalNode *) malloc(sizeof(generalNode));
			$$->lineNumber=$2;
			if ($4->type==1 && $6->type==1){ //int * int
				$$->type=1;
				$$->intVal=$4->intVal * $6->intVal;
				$$->mismatch=false;
				$$->constantexp=true;
				$$->toplevel=true;
			}
			else if($4->type==2 && $6->type==2){ //real num * real num
				$$->type=2;
				$$->realVal=$4->realVal * $6->realVal;
				$$->mismatch=false;
				$$->constantexp=true;
				$$->toplevel=true;
			}
			else if($4->type==3 && $6->type==3){ //both string
				$$->mismatch=true;
				$$->constantexp=false;		
				if ($4->toplevel==true){
					$$->constantexp=false;	
					if($4->type==1){
						$$->type=1;
						$$->intVal=$4->intVal;
						$$->mismatchTop=true;
					}
					else if($4->type==2){
						$$->type=2;
						$$->realVal=$4->realVal;
						$$->mismatchTop=true;
					}
					else if($4->type==3){
						$$->type=3;
						$$->strVal=$4->strVal;
						$$->mismatchTop=true;
					}
				}
				else if($6->toplevel==true){
					$$->constantexp=false;	
					if($6->type==1){
						$$->type=1;
						$$->intVal=$6->intVal;
						$$->mismatchTop=true;
					}
					else if($6->type==2){
						$$->type=2;
						$$->realVal=$6->realVal;
						$$->mismatchTop=true;
					}
					else if($6->type==3){
						$$->type=3;
						$$->strVal=$6->strVal;
						$$->mismatchTop=true;
					}
				}
			}
			else if($4->type==1 && $6->type==2){ // int * real -> value real
				$$->type=2;
				$$->realVal=$4->intVal * $6->realVal;
				$$->mismatch=false;
				$$->constantexp=true;
				$$->toplevel=true;
			}
			else if($4->type==2 && $6->type==1){ //real * int -> value real
				$$->type=2;
				$$->realVal=$4->realVal * $6->intVal;
				$$->mismatch=false;
				$$->constantexp=true;
				$$->toplevel=true;
			}
			else if($4->type==1 && $6->type==3){ //int * string -> valid if int >= 0
				if($4->intVal<0){
					$$->mismatch=true;
					$$->constantexp=false;		
					if ($4->toplevel==true){
						$$->constantexp=false;	
						if($4->type==1){
							$$->type=1;
							$$->intVal=$4->intVal;
							$$->mismatchTop=true;
						}
						else if($4->type==2){
							$$->type=2;
							$$->realVal=$4->realVal;
							$$->mismatchTop=true;
						}
						else if($4->type==3){
							$$->type=3;
							$$->strVal=$4->strVal;
							$$->mismatchTop=true;
						}
					}
					else if($6->toplevel==true){
						$$->constantexp=false;	
						if($6->type==1){
							$$->type=1;
							$$->intVal=$6->intVal;
							$$->mismatchTop=true;
						}
						else if($6->type==2){
							$$->type=2;
							$$->realVal=$6->realVal;
							$$->mismatchTop=true;
						}
						else if($6->type==3){
							$$->type=3;
							$$->strVal=$6->strVal;
							$$->mismatchTop=true;
						}
					}
				}
				else{
					if($6->constantexp==true){
						$$->type=3;
						$$->mismatch=false;
						$$->constantexp=true;
						char * temp = (char *) malloc(1 + $4->intVal * strlen($6->strVal));
						strcpy(temp, $6->strVal);
						int i;
						for(i = 1; i < $4->intVal; i = i + 1)
						{
							strcat(temp, $6->strVal);
						}
						$$->strVal = temp;	
						$$->toplevel=true;
					}
					else{
						$$->constantexp=false;
					}
				}
			}
			else if($4->type==2 && $6->type==3){ //real * string -> invalid
				$$->mismatch=true;
				$$->constantexp=false;		
				if ($4->toplevel==true){
					$$->constantexp=false;	
					if($4->type==1){
						$$->type=1;
						$$->intVal=$4->intVal;
						$$->mismatchTop=true;
					}
					else if($4->type==2){
						$$->type=2;
						$$->realVal=$4->realVal;
						$$->mismatchTop=true;
					}
					else if($4->type==3){
						$$->type=3;
						$$->strVal=$4->strVal;
						$$->mismatchTop=true;
					}
				}
				else if($6->toplevel==true){
					$$->constantexp=false;	
					if($6->type==1){
						$$->type=1;
						$$->intVal=$6->intVal;
						$$->mismatchTop=true;
					}
					else if($6->type==2){
						$$->type=2;
						$$->realVal=$6->realVal;
						$$->mismatchTop=true;
					}
					else if($6->type==3){
						$$->type=3;
						$$->strVal=$6->strVal;
						$$->mismatchTop=true;
					}
				}
			}
			else if($4->type==3 && $6->type==1){ //string * int -> invalid
				$$->mismatch=true;
				$$->constantexp=false;		
				if ($4->toplevel==true){
					$$->constantexp=false;	
					if($4->type==1){
						$$->type=1;
						$$->intVal=$4->intVal;
						$$->mismatchTop=true;
					}
					else if($4->type==2){
						$$->type=2;
						$$->realVal=$4->realVal;
						$$->mismatchTop=true;
					}
					else if($4->type==3){
						$$->type=3;
						$$->strVal=$4->strVal;
						$$->mismatchTop=true;
					}
				}
				else if($6->toplevel==true){
					$$->constantexp=false;	
					if($6->type==1){
						$$->type=1;
						$$->intVal=$6->intVal;
						$$->mismatchTop=true;
					}
					else if($6->type==2){
						$$->type=2;
						$$->realVal=$6->realVal;
						$$->mismatchTop=true;
					}
					else if($6->type==3){
						$$->type=3;
						$$->strVal=$6->strVal;
						$$->mismatchTop=true;
					}
				}
			}
			else if($4->type==3 && $6->type==2){ //string * real -> invalid
				$$->mismatch=true;
				$$->constantexp=false;		
				if ($4->toplevel==true){
					$$->constantexp=false;	
					if($4->type==1){
						$$->type=1;
						$$->intVal=$4->intVal;
						$$->mismatchTop=true;
					}
					else if($4->type==2){
						$$->type=2;
						$$->realVal=$4->realVal;
						$$->mismatchTop=true;
					}
					else if($4->type==3){
						$$->type=3;
						$$->strVal=$4->strVal;
						$$->mismatchTop=true;
					}
				}
				else if($6->toplevel==true){
					$$->constantexp=false;	
					if($6->type==1){
						$$->type=1;
						$$->intVal=$6->intVal;
						$$->mismatchTop=true;
					}
					else if($6->type==2){
						$$->type=2;
						$$->realVal=$6->realVal;
						$$->mismatchTop=true;
					}
					else if($6->type==3){
						$$->type=3;
						$$->strVal=$6->strVal;
						$$->mismatchTop=true;
					}
				}
			}
			else{
				if($4->mismatch==true || $6->mismatch==true){
					$$->mismatch = true;
					if($4->mismatch==true){
						insertPtr($4);
					}
				}
				else if($4->toplevel==true || $6->toplevel==true){
					$$->toplevel=true;
					if ($4->toplevel==true){
						$$->constantexp=false;	
						if($4->type==1){
							$$->type=1;
							$$->intVal=$4->intVal;
						}
						else if($4->type==2){
							$$->type=2;
							$$->realVal=$4->realVal;
						}
						else if($4->type==3){
							$$->type=3;
							$$->strVal=$4->strVal;
						}
					}
					else if($6->toplevel==true){
						$$->constantexp=false;	
						if($6->type==1){
							$$->type=1;
							$$->intVal=$6->intVal;
						}
						else if($6->type==2){
							$$->type=2;
							$$->realVal=$6->realVal;
						}
						else if($6->type==3){
							$$->type=3;
							$$->strVal=$6->strVal;
						}
					}
				}
			}
		}
		| '[' tDIV ',' expr ',' expr ']' {
			$$ = (generalNode*)malloc(sizeof(generalNode));
			$$->lineNumber=$2;
			if ($4->type==1 && $6->type==1){ //int / int
				$$->type=1;
				$$->intVal=$4->intVal / $6->intVal;
				$$->mismatch=false;
				$$->constantexp=true;
				$$->toplevel=true;
			}
			else if($4->type==2 && $6->type==2){ //real num / real num
				$$->type=2;
				$$->realVal=$4->realVal / $6->realVal;
				$$->mismatch=false;
				$$->constantexp=true;
				$$->toplevel=true;
			}
			else if($4->type==3 && $6->type==3){ //both string
				$$->mismatch=true;
				$$->constantexp=false;		
				if ($4->toplevel==true){
					$$->constantexp=false;	
					if($4->type==1){
						$$->type=1;
						$$->intVal=$4->intVal;
						$$->mismatchTop=true;
					}
					else if($4->type==2){
						$$->type=2;
						$$->realVal=$4->realVal;
						$$->mismatchTop=true;
					}
					else if($4->type==3){
						$$->type=3;
						$$->strVal=$4->strVal;
						$$->mismatchTop=true;
					}
				}
				else if($6->toplevel==true){
					$$->constantexp=false;	
					if($6->type==1){
						$$->type=1;
						$$->intVal=$6->intVal;
						$$->mismatchTop=true;
					}
					else if($6->type==2){
						$$->type=2;
						$$->realVal=$6->realVal;
						$$->mismatchTop=true;
					}
					else if($6->type==3){
						$$->type=3;
						$$->strVal=$6->strVal;
						$$->mismatchTop=true;
					}
				}
			}
			else if($4->type==1 && $6->type==2){ // int / real -> value real
				$$->type=2;
				$$->realVal=$4->intVal / $6->realVal;
				$$->mismatch=false;
				$$->constantexp=true;
				$$->toplevel=true;
			}
			else if($4->type==2 && $6->type==1){ //real / int -> value real
				$$->type=2;
				$$->realVal=$4->realVal / $6->intVal;
				$$->mismatch=false;
				$$->constantexp=true;
				$$->toplevel=true;
			}
			else if($4->type==1 && $6->type==3){ //int / string -> invalid
				$$->mismatch=true;
				$$->constantexp=false;		
				if ($4->toplevel==true){
					$$->constantexp=false;	
					if($4->type==1){
						$$->type=1;
						$$->intVal=$4->intVal;
						$$->mismatchTop=true;
					}
					else if($4->type==2){
						$$->type=2;
						$$->realVal=$4->realVal;
						$$->mismatchTop=true;
					}
					else if($4->type==3){
						$$->type=3;
						$$->strVal=$4->strVal;
						$$->mismatchTop=true;
					}
				}
				else if($6->toplevel==true){
					$$->constantexp=false;	
					if($6->type==1){
						$$->type=1;
						$$->intVal=$6->intVal;
						$$->mismatchTop=true;
					}
					else if($6->type==2){
						$$->type=2;
						$$->realVal=$6->realVal;
						$$->mismatchTop=true;
					}
					else if($6->type==3){
						$$->type=3;
						$$->strVal=$6->strVal;
						$$->mismatchTop=true;
					}
				}
			}
			else if($4->type==2 && $6->type==3){ //real / string -> invalid
				$$->mismatch=true;
				$$->constantexp=false;		
				if ($4->toplevel==true){
					$$->constantexp=false;	
					if($4->type==1){
						$$->type=1;
						$$->intVal=$4->intVal;
						$$->mismatchTop=true;
					}
					else if($4->type==2){
						$$->type=2;
						$$->realVal=$4->realVal;
						$$->mismatchTop=true;
					}
					else if($4->type==3){
						$$->type=3;
						$$->strVal=$4->strVal;
						$$->mismatchTop=true;
					}
				}
				else if($6->toplevel==true){
					$$->constantexp=false;	
					if($6->type==1){
						$$->type=1;
						$$->intVal=$6->intVal;
						$$->mismatchTop=true;
					}
					else if($6->type==2){
						$$->type=2;
						$$->realVal=$6->realVal;
						$$->mismatchTop=true;
					}
					else if($6->type==3){
						$$->type=3;
						$$->strVal=$6->strVal;
						$$->mismatchTop=true;
					}
				}
			}
			else if($4->type==3 && $6->type==1){ //string / int -> invalid
				$$->mismatch=true;
				$$->constantexp=false;		
				if ($4->toplevel==true){
					$$->constantexp=false;	
					if($4->type==1){
						$$->type=1;
						$$->intVal=$4->intVal;
						$$->mismatchTop=true;
					}
					else if($4->type==2){
						$$->type=2;
						$$->realVal=$4->realVal;
						$$->mismatchTop=true;
					}
					else if($4->type==3){
						$$->type=3;
						$$->strVal=$4->strVal;
						$$->mismatchTop=true;
					}
				}
				else if($6->toplevel==true){
					$$->constantexp=false;	
					if($6->type==1){
						$$->type=1;
						$$->intVal=$6->intVal;
						$$->mismatchTop=true;
					}
					else if($6->type==2){
						$$->type=2;
						$$->realVal=$6->realVal;
						$$->mismatchTop=true;
					}
					else if($6->type==3){
						$$->type=3;
						$$->strVal=$6->strVal;
						$$->mismatchTop=true;
					}
				}
			}
			else if($4->type==3 && $6->type==2){ //string / real -> invalid
				$$->mismatch=true;
				$$->constantexp=false;		
				if ($4->toplevel==true){
					$$->constantexp=false;	
					if($4->type==1){
						$$->type=1;
						$$->intVal=$4->intVal;
						$$->mismatchTop=true;
					}
					else if($4->type==2){
						$$->type=2;
						$$->realVal=$4->realVal;
						$$->mismatchTop=true;
					}
					else if($4->type==3){
						$$->type=3;
						$$->strVal=$4->strVal;
						$$->mismatchTop=true;
					}
				}
				else if($6->toplevel==true){
					$$->constantexp=false;	
					if($6->type==1){
						$$->type=1;
						$$->intVal=$6->intVal;
						$$->mismatchTop=true;
					}
					else if($6->type==2){
						$$->type=2;
						$$->realVal=$6->realVal;
						$$->mismatchTop=true;
					}
					else if($6->type==3){
						$$->type=3;
						$$->strVal=$6->strVal;
						$$->mismatchTop=true;
					}
				}
			}
			else{
				if($4->mismatch==true || $6->mismatch==true){
					$$->mismatch = true;
					if($4->mismatch==true){
						insertPtr($4);
					}
				}
				else if($4->toplevel==true || $6->toplevel==true){
					$$->toplevel=true;
					if ($4->toplevel==true){
						$$->constantexp=false;	
						if($4->type==1){
							$$->type=1;
							$$->intVal=$4->intVal;
						}
						else if($4->type==2){
							$$->type=2;
							$$->realVal=$4->realVal;
						}
						else if($4->type==3){
							$$->type=3;
							$$->strVal=$4->strVal;
						}
					}
					else if($6->toplevel==true){
						$$->constantexp=false;	
						if($6->type==1){
							$$->type=1;
							$$->intVal=$6->intVal;
						}
						else if($6->type==2){
							$$->type=2;
							$$->realVal=$6->realVal;
						}
						else if($6->type==3){
							$$->type=3;
							$$->strVal=$6->strVal;
						}
					}
				}
			}
		}
;	

unaryOperation: '[' tINC ',' tIDENT ']'
		| '[' tDEC ',' tIDENT ']'
;

expr:		
tREAL {
	$$ = (generalNode*)malloc(sizeof(generalNode));
	$$->type = 2;
    $$->realVal = $1;
	$$->lineNumber = numLine;	
	$$->constantexp = true;
}
|
tINT{
	$$ = (generalNode*)malloc(sizeof(generalNode));
	$$->type = 1;
    $$->intVal = $1;
	$$->lineNumber = numLine;	
	$$->constantexp = true;
}
| 
tSTRING {
	$$ = (generalNode*)malloc(sizeof(generalNode));
    $$->strVal = $1;
	$$->lineNumber = numLine;
	$$->type=3;
	$$->constantexp = true;
}
| 
getExpr { //
	$$ = (generalNode*)malloc(sizeof(generalNode));
	if ($1->type==1){
		$$->type=$1->type;
		$$->constantexp=$1->constantexp;
		$$->intVal=$1->intVal;
		$$->lineNumber=numLine;
		$$->mismatch=$1->mismatch;
	}
	else if($1->type==2){
		$$->type=$1->type;
		$$->constantexp=$1->constantexp;
		$$->realVal=$1->realVal;
		$$->lineNumber=numLine;
		$$->mismatch=$1->mismatch;
	}
	else if($1->type==3){
		$$->type=$1->type;
		$$->constantexp=$1->constantexp;
		$$->strVal=$1->strVal;
		$$->lineNumber=numLine;
		$$->mismatch=$1->mismatch;
	}
	else{
		$$->lineNumber=numLine;
		$$->mismatch=$1->mismatch;
		$$->constantexp=$1->constantexp;
	}
}
| 
function { //
	$$ = (generalNode*)malloc(sizeof(generalNode));
	if ($1->type==1){
		$$->type=$1->type;
		$$->constantexp=$1->constantexp;
		$$->intVal=$1->intVal;
		$$->lineNumber=numLine;
		$$->mismatch=$1->mismatch;
	}
	else if($1->type==2){
		$$->type=$1->type;
		$$->constantexp=$1->constantexp;
		$$->realVal=$1->realVal;
		$$->lineNumber=numLine;
		$$->mismatch=$1->mismatch;
	}
	else if($1->type==3){
		$$->type=$1->type;
		$$->constantexp=$1->constantexp;
		$$->strVal=$1->strVal;
		$$->lineNumber=numLine;
		$$->mismatch=$1->mismatch;
	}
	
} 
|
operation { //
	$$ = (generalNode*)malloc(sizeof(generalNode));
	if ($1->type==1){
		$$->type=$1->type;
		$$->constantexp=$1->constantexp;
		$$->intVal=$1->intVal;
		$$->lineNumber=numLine;
		$$->mismatch=$1->mismatch;
		if ($1->toplevel==true){
			$$->toplevel=true;
		}
		if ($1->mismatchTop==true){
			$$->mismatchTop=true;
		}
	}
	else if($1->type==2){
		$$->type=$1->type;
		$$->constantexp=$1->constantexp;
		$$->realVal=$1->realVal;
		$$->lineNumber=numLine;
		$$->mismatch=$1->mismatch;
		if ($1->toplevel==true){
			$$->toplevel=true;
		}
		if ($1->mismatchTop==true){
			$$->mismatchTop=true;
		}
	}
	else if($1->type==3){
		$$->type=$1->type;
		$$->constantexp=$1->constantexp;
		$$->strVal=$1->strVal;
		$$->lineNumber=numLine;
		$$->mismatch=$1->mismatch;
		if ($1->toplevel==true){
			$$->toplevel=true;
		}
		if ($1->mismatchTop==true){
			$$->mismatchTop=true;
		}
	}
	else{
		$$->lineNumber=numLine;
		$$->mismatch=$1->mismatch;
		$$->constantexp=$1->constantexp;
	}
}
| 
condition { //
	$$ = (generalNode*)malloc(sizeof(generalNode));
	if ($1->type==1){
		$$->type=$1->type;
		$$->constantexp=$1->constantexp;
		$$->intVal=$1->intVal;
		$$->lineNumber=numLine;
		$$->mismatch=$1->mismatch;
	}
	else if($1->type==2){
		$$->type=$1->type;
		$$->constantexp=$1->constantexp;
		$$->realVal=$1->realVal;
		$$->lineNumber=numLine;
		$$->mismatch=$1->mismatch;
	}
	else if($1->type==3){
		$$->type=$1->type;
		$$->constantexp=$1->constantexp;
		$$->strVal=$1->strVal;
		$$->lineNumber=numLine;
		$$->mismatch=$1->mismatch;
	}
}
;

function:	 '[' tFUNCTION ',' '[' parametersList ']' ',' '[' stmtlst ']' ']'
		| '[' tFUNCTION ',' '[' ']' ',' '[' stmtlst ']' ']'
;

condition:	'[' tEQUALITY ',' expr ',' expr ']'{
	$$ = (generalNode*)malloc(sizeof(generalNode));
	$$->mismatch=$4->mismatch;
	$$->lineNumber=numLine;
	$$->constantexp=$4->constantexp;
	insertPtr($4);
	insertPtr($6);
}
		| '[' tGT ',' expr ',' expr ']'{
			$$ = (generalNode*)malloc(sizeof(generalNode));
			$$->mismatch=$4->mismatch;
			$$->lineNumber=numLine;
			$$->constantexp=$4->constantexp;
			insertPtr($4);
			insertPtr($6);
		}
		| '[' tLT ',' expr ',' expr ']'{
			$$ = (generalNode*)malloc(sizeof(generalNode));
			$$->mismatch=$4->mismatch;
			$$->lineNumber=numLine;
			$$->constantexp=$4->constantexp;
			insertPtr($4);
			insertPtr($6);
		}
		| '[' tGEQ ',' expr ',' expr ']'{
			$$ = (generalNode*)malloc(sizeof(generalNode));
			$$->mismatch=$4->mismatch;
			$$->lineNumber=numLine;
			$$->constantexp=$4->constantexp;
			insertPtr($4);
			insertPtr($6);
		}
		| '[' tLEQ ',' expr ',' expr ']'{
			$$ = (generalNode*)malloc(sizeof(generalNode));
			$$->mismatch=$4->mismatch;
			$$->lineNumber=numLine;
			$$->constantexp=$4->constantexp;
			insertPtr($4);
			insertPtr($6);
		}
;

returnStmt:	'[' tRETURN ',' expr ']'{
	$$ = (generalNode*)malloc(sizeof(generalNode));
	$$->mismatch=$4->mismatch;
	$$->lineNumber=numLine;
	$$->constantexp=$4->constantexp;
	$$->type=$4->type;
	if($$->type==1){
		$$->intVal=$4->intVal;
	}
	else if($$->type==2){
		$$->realVal=$4->realVal;
	}
	else if($$->type==3){
		$$->strVal=$4->strVal;
	}
}
		| '[' tRETURN ']' {
			$$ = (generalNode*)malloc(sizeof(generalNode));
			$$->constantexp=false;
			$$->mismatch=false;
		}
;

parametersList: parametersList ',' tIDENT | tIDENT
;

exprList:	exprList ',' expr {
	insertPtr($3);
}
| expr{
	insertPtr($1);
}
;

%%

void insertPtr(generalNode *nodePtr){
	if(head==NULL){
		struct printNode * addNode = (struct printNode*)malloc(sizeof(struct printNode));
		addNode->generalNodePtr = nodePtr;
		addNode->next=NULL;
		head = addNode;
	}
	else{
		struct printNode *temp;
		temp = head;
		while(temp->next!=NULL){
			temp=temp->next;
		}
		struct printNode * addNode = (struct printNode*)malloc(sizeof(struct printNode));
		addNode->generalNodePtr = nodePtr;
		addNode->next = NULL;
		temp->next = addNode;
	}

}

void printPtr(printNode *head){
	struct printNode * temp=head;
	if(temp==NULL){
		return;
	}
	while (temp!=NULL){
		
			if(temp->generalNodePtr->mismatch==true){
				printf("Type mismatch on %d\n",temp->generalNodePtr->lineNumber);
				if(temp->generalNodePtr->mismatchTop==true){
					if(temp->generalNodePtr->type==1){
						printf("Result of expression on %d is (%d)\n",temp->generalNodePtr->lineNumber, temp->generalNodePtr->intVal);
					}
					else if(temp->generalNodePtr->type==2){
						printf("Result of expression on %d is (%.1lf)\n",temp->generalNodePtr->lineNumber, temp->generalNodePtr->realVal);
					}
					else if(temp->generalNodePtr->type==3){
						printf("Result of expression on %d is (%s)\n",temp->generalNodePtr->lineNumber, temp->generalNodePtr->strVal);
					}
					else{		

					}
				}
			}
			else if((temp->generalNodePtr->mismatch==false) && (temp->generalNodePtr->constantexp==false)){
				if(temp->generalNodePtr->toplevel==true){
					if(temp->generalNodePtr->type==1){
						printf("Result of expression on %d is (%d)\n",temp->generalNodePtr->lineNumber, temp->generalNodePtr->intVal);
					}
					else if(temp->generalNodePtr->type==2){
						printf("Result of expression on %d is (%.1lf)\n",temp->generalNodePtr->lineNumber, temp->generalNodePtr->realVal);
					}
					else if(temp->generalNodePtr->type==3){
						printf("Result of expression on %d is (%s)\n",temp->generalNodePtr->lineNumber, temp->generalNodePtr->strVal);
					}
					else{		

					}
				}
				else{}
			
			}
			else{
				if(temp->generalNodePtr->type==1){
					printf("Result of expression on %d is (%d)\n",temp->generalNodePtr->lineNumber, temp->generalNodePtr->intVal);
				}
				else if(temp->generalNodePtr->type==2){
					printf("Result of expression on %d is (%.1lf)\n",temp->generalNodePtr->lineNumber, temp->generalNodePtr->realVal);
				}
				else if(temp->generalNodePtr->type==3){
					printf("Result of expression on %d is (%s)\n",temp->generalNodePtr->lineNumber, temp->generalNodePtr->strVal);
				}
				else{
					
				}
			}
		temp=temp->next;
	}

}

int main ()
{
	if (yyparse()) {
		// parse error
		printf("ERROR\n");
		return 1;
	}
	else {
		// successful parsing
		printPtr(head);
		return 0;
	}
}
