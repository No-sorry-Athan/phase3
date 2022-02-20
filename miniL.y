    /* cs152-miniL phase2 */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

struct Node{
  std::string code;
  std::string name;
};

void yyerror(const char *msg);
%}

%union{
 int ival;
 char* sval;
}



%error-verbose
%locations
%start prog_start
%left FUNCTION SEMICOLON BPARAMS EPARAMS BLOCALS ELOCALS BBODY EBODY BLOOP ENLOOP
%left INTEGER OF IF THEN ENDIF ELSE DO TRUE FALSE RETURN
%left ARRAY CONTINUE WHILE BREAK READ WRITE  
%left ADD SUB MULT DIV MOD 
%left EQ NEQ GT LT GTE LTE 
%left COLON COMMA L_PAREN L_SQUARE_BRACKET R_PAREN R_SQUARE_BRACKET 
%right NOT
%right ASSIGN
%token inv_symbol
%token <ival> NUMBER
%token <sval> IDENTIFIER

%type <sval> identifier
%type <ival> number

/* %start program */
%%
prog_start: functions {printf("prog_start -> functions\n");};
functions: F functions {printf("functions -> functions function\n"); }| {printf("functions -> epsilon\n");};
F: FUNCTION identifier SEMICOLON BPARAMS D EPARAMS BLOCALS D ELOCALS BBODY S1 EBODY
 {
  std::string ident = $2; 
  printf("%s\n\n\n", ident.c_str());

  printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");
 };
D: D D1 SEMICOLON {
  printf("declaration -> declaration declarations SEMICOLON\n"); }| { printf("declaration -> epsilon\n");
  
 };
D1: identifier COLON A INTEGER { 
  printf("declarations -> IDENT COLON arrays INTEGER\n"); 
  /*
    variables a / b
    add to mil 
    seperate into two "declrations"
    one for inbtw params 
    one for inbtw locals
  */

};
A: ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF {
  printf("arrays -> ARRAY L_SQUARE_BRACKET number %d R_SQUARE_BRACKET OF\n", yylval);
  /*
     array case: array variable
     output to mil
     .[] ident(??), %d (yylval)
  */
 }
 | {
   /* empty case: regular variable 
      . ident
   */
   printf("arrays -> epsilon\n");
   };
S: S1 S2 {printf("statements -> statements1 statement2\n");};
S1: S1 S2 SEMICOLON {printf("statements1 -> statements1 statement2 SEMICOLON\n");}| {printf("statements1 -> epsilon\n");};
S2: IF BE THEN S1 ES ENDIF { printf("statement2 -> IF bool_exp THEN statements else ENDIF\n"); }
  | V ASSIGN E {
    printf("statement2 -> var ASSIGN expression\n"); 
    /*  assignment case */
    }
  | WHILE BE BLOOP S1 ENLOOP {printf("statement2 -> WHILE bool_exp BLOOP statements ENLOOP\n");}
  | DO BLOOP S ENLOOP WHILE BE {printf("statement2 -> DO BLOOP statements ENLOOP WHILE bool_exp\n"); }
  | READ V {printf("statement2 -> READ var\n");}
  | WRITE V {printf("statement2 -> WRITE var\n");}
  | CONTINUE {printf("statement2 -> CONTINUE\n");}
  | BREAK {printf("statement2 -> BREAK\n");}
  | RETURN E {printf("statement2 -> RETURN expression\n");} 
ES: ELSE S1 {printf("else -> ELSE statements\n"); }| {printf("else -> epsilon\n"); };
BE: N E C E {printf("bool_exp -> not expression comparison expression\n");} 
  | {printf("bool_exp -> epsilon\n");}; 
N: NOT N {printf("not -> NOT not\n");} | {printf("not -> epsilon\n");} ;
C: EQ {printf("comparison -> EQ\n"); }
  | NEQ {printf("comparison -> NEQ\n"); }
  | LT {printf("comparison -> LT\n"); }
  | GT {printf("comparison -> GT\n"); }
  | LTE {printf("comparison -> LTE\n"); }
  | GTE {printf("comparison -> GTE\n"); }; 
E: ME ATERM {printf("expression -> mult_exp add_term\n"); }
ATERM: AOP ME ATERM {printf("add_term -> add_op mult_exp add_term\n");}| {printf("add_term -> epsilon\n");};
AOP: ADD {printf("add_op -> ADD\n");}
  | SUB {printf("add_op -> SUB\n");} ;
ME: T MTERM {printf("mult_exp -> term mult_term\n");}
MTERM: MOP T MTERM {printf("mult_term -> mult_op term mult_term\n"); }| {printf("mult_term -> epsilon\n"); };
MOP: MULT {printf("mult_op -> MULT\n");}
  |  DIV {printf("mult_op -> DIV\n"); }
  |  MOD {printf("mult_op -> MOD\n");};
T: V {printf("term -> var\n");}
  | number {printf("term -> number %d\n", yylval); }
  | L_PAREN E R_PAREN {printf("term -> L_PAREN expression R_PAREN\n"); }
  | identifier L_PAREN ECL R_PAREN {printf("term -> identifier L_PAREN expression_comma_loop R_PAREN\n");}
ECL: E COMMA ECL {printf("expression_comma_loop -> expression COMMA expression_comma_loop\n");}
  | E {printf("expression_comma_loop -> expression\n");}
  | {printf("expression_comma_loop -> epsilon\n");}; 
V: identifier V1 {printf("var -> identifier vars\n");}
V1: L_SQUARE_BRACKET E R_SQUARE_BRACKET {printf("vars -> L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
  | {printf("vars -> epsilon\n");};
identifier: IDENTIFIER {
  /*Node *node = new Node();
  node->code = "";
  node->name = $1;
  printf("%s\n", node->name.c_str());*/

  printf("identifier -> IDENT %s\n", yylval.sval);
  $$ = $1;
  }
number: NUMBER {
  
  printf("number -> NUMBER %d\n", yylval.ival);
  $$ = $1;
  }
%%

int main(int argc, char **argv) {
   yyin = stdin;
   if (argc > 1){
      yyin = fopen(argv[1], "r");
   }
   yyparse();
   return 0;
}

void yyerror(const char *msg) {
    printf("Syntax error at line %d: %s\n", yylloc.last_line, msg);
}


