/* cs152-miniL phase1 */
%{ 
	#include <stdio.h>
    #include "miniL-parser.hpp"
	#define YY_DECL int yylex() 
	int currentRow = 1;
%}
   
	/* reserved words */
FUNCTION        "function"
BEGIN_PARAMS    "beginparams"
END_PARAMS      "endparams"
BEGIN_LOCALS    "beginlocals"
END_LOCALS      "endlocals"
BEGIN_BODY      "beginbody"
END_BODY        "endbody"
INTEGER         "integer"
ARRAY           "array"
OF              "of"
IF              "if"
THEN            "then"
ENDIF           "endif"
ELSE            "else"
WHILE           "while"
DO              "do"
BEGINLOOP       "beginloop"
ENDLOOP         "endloop"
CONTINUE        "continue"
BREAK           "break"
READ            "read"
WRITE           "write"
NOT             "not"
TRUE            "true"
FALSE           "false"
RETURN          "return"

	/* arithmetic operators */
ADD		"+"
SUB		"-"
MULT		"*"
DIV		"/"
MOD		"%"
  
	/* comparison operators */
EQ    "=="
NEQ   "<>"
LT    "<"     
GT    ">"
LTE   "<="
GTE   ">="

	/* identifiers and numbers */
IDENT			[a-zA-Z]+([a-zA-Z0-9_]*[a-zA-Z0-9])*
IDENT_ERROR_1	[0-9_]+[a-zA-Z]+([a-zA-Z0-9_]*[a-zA-Z0-9])*
IDENT_ERROR_2	[a-zA-Z]+([a-zA-Z0-9_]*[a-zA-Z0-9])*_+
NUMBER			[0-9]+

	/* special symbols */
SEMICOLON        ";"
COLON            ":"
COMMA            ","
L_PAREN          "("
R_PAREN          ")"
L_SQUARE_BRACKET "["
R_SQUARE_BRACKET "]"
ASSIGN           ":="

	/* other */
COMMENT_STRING	[#][#][^\n]*[\n]
NEWLINE		^[\n]
WHITESPACE	[\r\t\f\v ]

%%
{FUNCTION} { return FUNCTION;}
{BEGIN_PARAMS} { return BPARAMS;}
{END_PARAMS}  { return EPARAMS;}
{BEGIN_LOCALS} { return BLOCALS;}
{END_LOCALS} { return ELOCALS;}
{BEGIN_BODY} { return BBODY;}
{END_BODY} { return EBODY;}
{INTEGER} { return INTEGER; }
{ARRAY}	{ return ARRAY; }
{OF} { return OF; }
{IF} { return IF;}
{THEN}"\n" { currentRow++; return THEN; }
{THEN}	{ return THEN; }
{ENDIF}	 { return ENDIF; }
{ELSE}	{ return ELSE; }
{WHILE}						{ return WHILE; }
{DO}						{ return DO; }
{BEGINLOOP}					{ return BLOOP; }
{ENDLOOP}					{ return ENLOOP; }
{CONTINUE}					{ return CONTINUE; }
{BREAK}						{ return BREAK; }
{READ}						{ return READ; }
{WRITE}						{ return WRITE;}
{NOT}						{ return NOT; }
{TRUE}						{ return TRUE; }
{FALSE}						{ return FALSE; }
{RETURN}					{ return RETURN; }

	/* arithmetic operators */

{ADD}          { return ADD; }
{SUB}          { return SUB; }
{MULT}         { return MULT; }
{DIV}          { return DIV; }
{MOD}          { return MOD; }

	/* comparison operators */

{LTE}          { return LTE; }
{GTE}          { return GTE; }
{EQ}           { return EQ; }
{NEQ}          { return NEQ; }
{LT}           { return LT; }
{GT}           { return GT; }

	/* identifiers */
{IDENT_ERROR_1}       { printf("Error at line %d, identifier \"%s\" must begin with a letter.", currentRow, yytext); return 1;}
{IDENT_ERROR_2}       { printf("Error at line %d, identifier \"%s\" cannot end with an underscore.", currentRow,  yytext); return 1;}
{IDENT}               { yylval.sval = strdup(yytext); return IDENTIFIER;  }
{NUMBER}              { yylval.ival = atoi(strdup(yytext)); return NUMBER; }

	/* special symbols*/

{SEMICOLON}"\n"      { currentRow++; yylloc.last_line++; return SEMICOLON; }
{SEMICOLON}          { return SEMICOLON;}
{COLON}              { return COLON; }
{COMMA}       	     { return COMMA; }
{L_PAREN}            { return L_PAREN; }
{R_PAREN}            { return R_PAREN; }
{L_SQUARE_BRACKET}   { return L_SQUARE_BRACKET; }
{R_SQUARE_BRACKET}   { return R_SQUARE_BRACKET; }
{ASSIGN}             { return ASSIGN; }
{WHITESPACE}         {}


	/* other */
   {COMMENT_STRING}            {currentRow++; yylloc.last_line++;} 
   {NEWLINE}                   {currentRow++; yylloc.last_line++;}
   [\n]                        {currentRow++; yylloc.last_line++;}

   [^\n]                       { return inv_symbol; }
%%
	/* C functions used in lexer */

