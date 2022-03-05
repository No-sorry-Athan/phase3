    /* cs152-miniL phase2 */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <string.h>
#include <vector>
#include <algorithm>
#include <iostream>

extern int yylex();
extern int yyparse();
extern FILE* yyin;
extern FILE* yyout;

extern std::string params = "";
extern std::string paramtails = "";
extern int count = 0;
extern int tmpCount = 0;
extern int loopCount = 0;
extern int ifCount = 0;

struct Function {
  std::string name;
  std::vector<std::string> decparams1;
  std::vector<std::string> decparams2;
  std::vector<std::string> declocals;
  std::vector<std::string> statements;
};
std::vector<Function> symbol_table;

void addFunction(std::string &value) {
  Function f;
  f.name = value;
  symbol_table.push_back(f);
}

Function *getFunction() { return &symbol_table[symbol_table.size()-1]; }

void addDecParam1(std::string &value) {
  Function *f = getFunction();
  f->decparams1.push_back(value);
}

void addDecParam2(std::string &value) {
  Function *f = getFunction();
  f->decparams2.push_back(value);
}

void addDecLocal(std::string &value) {
  Function *f = getFunction();
  f->declocals.push_back(value);
}

void addStatement(std::string &value) {
  Function *f = getFunction();
  f->statements.push_back(value);
}

void printSymbolTable() {
  printf("Symbol Table\n");
  printf("--------------------\n");
  for(Function f : symbol_table) {
    printf("function: %s\n", f.name.c_str());

    for(std::string decparam1 : f.decparams1) {
      printf("  params: %s\n", decparam1.c_str());
    }
    for(std::string decparam2 : f.decparams2) {
      printf("  params: %s\n", decparam2.c_str());
    }
    if (!f.decparams2.empty())
      printf("\n");

    for(std::string declocal : f.declocals) {
      printf("  locals: %s\n", declocal.c_str());
    }
    if (!f.declocals.empty())
      printf("\n");
    for(std::string statement : f.statements) {
      printf("  statements: %s\n", statement.c_str());
    }
    printf("endfunc\n\n");
  }
  printf("--------------------\n");
}

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
%type <sval> S1
%type <sval> S2
%type <sval> E
%type <sval> C
%type <sval> V
%type <sval> N
%type <sval> T
%type <sval> BE
%type <sval> ECL
%type <sval> MOP
%type <sval> ifBE
%type <sval> ME
%type <sval> AOP

/* %start program */
%%
// absorb function (1+) or end
prog_start: functions;

functions: F functions | ;
F: FUNCTION identifier SEMICOLON {
  std::string ident = $2; 
  // yyout << "func " << ident << "\n";
  std::string temp = "func " + ident + "\n";
  fprintf(yyout, temp.c_str());
  printf("func %s\n", ident.c_str());
  addFunction(ident);
  //printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");
  } BPARAMS DECPARAM PRINTPARAMS EPARAMS BLOCALS DECLOCALS ELOCALS BBODY S1 EBODY {printf("endfunc\n\n"); fprintf(yyout, "endfunc\n\n"); };

DECPARAM : identifier COLON INTEGER SEMICOLON { 
    std::string ident = $1; 
    params = params + ". " + ident.c_str() + "\n";
    std::string dcp1 = ". " + ident;
    addDecParam1(dcp1);
    std::string dcp2 = "= " + ident + ", $" + std::to_string(count);
    addDecParam2(dcp2);
    paramtails = paramtails + "= " + ident.c_str() + ", $" + std::to_string(count++) + "\n";
    } DECPARAM 
  | identifier COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER SEMICOLON { 
      std::string ident = $1;
      int num = $5;
      std::string dcp1 = ".[] " + ident + ", " + std::to_string(num);
      params = params + ".[] " + ident + ", " + std::to_string(num);
      addDecParam1(dcp1);
      std::string dcp2 = "= " + ident + ", $" + std::to_string(count);
      addDecParam2(dcp2);
      paramtails = paramtails + "= " + ident + ", $" + std::to_string(count++) + "\n";
  } DECPARAM | ;
PRINTPARAMS : { printf("%s%s", params.c_str(), paramtails.c_str()); fprintf(yyout, params.c_str()); fprintf(yyout, paramtails.c_str()); params = ""; paramtails = ""; count = 0;}

DECLOCALS : identifier COLON INTEGER SEMICOLON { 
    std::string ident = $1; 
    std::string declocal = ". " + ident;
    std::string output = ". " + ident + "\n";
    printf(". %s\n", ident.c_str()); 
    fprintf(yyout, output.c_str());
    addDecLocal(declocal);
    } DECLOCALS 
  | identifier COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER SEMICOLON { 
      std::string ident = $1;
      int num = $5;
      std::string output_string = ".[] " + ident + ", " + std::to_string(num);
      printf("%s\n", output_string.c_str());
      std::string outputN = output_string + "\n";
      fprintf(yyout, outputN.c_str());
      addDecLocal(output_string);
  } DECLOCALS | ;

S1: S1 S2 SEMICOLON { /* printf("statements1 -> statements1 statement2 SEMICOLON\n"); */ $$ = $2;}
| /*{printf("statements1 -> epsilon\n");}*/;
S2:
  IF {ifCount++;} ifBE THEN {
  int currentLoop = ifCount - 1;
  std::string outputString = ": if_true" + std::to_string(currentLoop);
  printf("%s\n", outputString.c_str());
  std::string outputN = outputString + "\n";
  fprintf(yyout, outputN.c_str());
  }
    S1 { if ($6 != "break"){
      int currentLoop = ifCount - 1;
      std::string outputString = ":= endif" + std::to_string(currentLoop);
      printf("%s\n", outputString.c_str());
      std::string outputN = outputString + "\n";
      fprintf(yyout, outputN.c_str());
      } 
    }
    ES ENDIF { 
    int currentLoop = ifCount - 1;
    std::string outputString = ": endif" + std::to_string(currentLoop);
    printf("%s\n", outputString.c_str());
    std::string outputN = outputString + "\n";
    fprintf(yyout, outputN.c_str());
 
    // printf("statement2 -> IF bool_exp THEN statements else ENDIF\n"); 
    }
  | identifier L_SQUARE_BRACKET E R_SQUARE_BRACKET ASSIGN E { 
      std::string ident = $1;
      std::string e = $3;
      std::string rhs = $6;
      int equiv = std::atoi(rhs.c_str());
      if (equiv != 0){
        std::string outputString = "[]= " + ident + ", " + e + ", " + rhs; 
        std::string output = outputString + "\n";
        printf("%s\n", outputString.c_str());
        fprintf(yyout, output.c_str());
        addStatement(outputString);
      }
      else{
        int copyOfCount = tmpCount - 1;
        std::string temp = "_temp" + std::to_string(copyOfCount);
        std::string outputString = "[]= " + ident + ", " + e + ", " + temp; 
        std::string outputN = outputString + "\n";
        printf("%s\n", outputString.c_str());
        fprintf(yyout, outputN.c_str());
        addStatement(outputString);
      }
    } 
  | V ASSIGN E { /* printf("statement2 -> var ASSIGN expression\n"); */ 
  std::string v = $1;
  std::string e = $3;
  std::string outputString = "= " + v + ", " + e;
  std::string outputN = outputString + "\n";
  printf("= %s, %s\n", $1, $3); 
  fprintf(yyout, outputN.c_str());
  addStatement(outputString);}
  | WHILE { 
      std::string outputString = ": beginloop" + std::to_string(loopCount++);
      printf("%s\n", outputString.c_str());  
      std::string outputN = outputString + "\n";
      fprintf(yyout, outputN.c_str());
     } BE BLOOP 
     {  int currentLoop = loopCount - 1; 
     
        std::string outputString = ": loopbody" + std::to_string(currentLoop);
        printf("%s\n", outputString.c_str());  
        std::string outputN = outputString + "\n";
        fprintf(yyout, outputN.c_str());
      } S1 ENLOOP {
      int currentLoop = loopCount - 1; 
      loopCount --;
      std::string outputString1 = ":= beginloop" + std::to_string(currentLoop);
      printf("%s\n", outputString1.c_str());
      std::string output1N = outputString1 + "\n";
      fprintf(yyout, output1N.c_str());
      std::string outputString2 = ": endloop" + std::to_string(currentLoop);
      printf("%s\n", outputString2.c_str());
      std::string output2N = outputString2 + "\n";
      fprintf(yyout, output2N.c_str());
    // printf("statement2 -> WHILE bool_exp BLOOP statements ENLOOP\n");
    }
  | DO { std::string beginloop = ": beginloop" + std::to_string(loopCount++);
    printf("%s\n", beginloop.c_str()); } BLOOP S1 ENLOOP WHILE BE {
    
    printf("statement2 -> DO BLOOP statements ENLOOP WHILE bool_exp\n"); 
    }
  | READ V {
    printf("statement2 -> READ var\n");
    }
  | WRITE identifier L_SQUARE_BRACKET E R_SQUARE_BRACKET
  { 
    std::string temp = "_temp" + std::to_string(tmpCount++);
    std::string tempSymbol = ". " + temp;
    std::string tempN = tempSymbol + "\n";
    printf(". %s\n", temp.c_str());
    fprintf(yyout, tempN.c_str());
    addStatement(tempSymbol);
    std::string ident = $2;
    std::string e = $4;
    std::string output = "=[] " + temp + ", " + ident + ", " + e;
    std::string outputSymbol = output;
    std::string outputN = output + "\n";
    printf("%s\n", output.c_str());
    fprintf(yyout, outputN.c_str());
    addStatement(outputSymbol);

    std::string tempW = ".> " + temp + "\n";
    printf(".> %s\n", temp.c_str());
    fprintf(yyout, tempW.c_str());
    std::string writeTemp = ".> " + temp;
    addStatement(writeTemp);
  }
  | WRITE V {
    // printf("statement2 -> WRITE var\n");
    std::string var = $2;
    std::string writeVar = ".> " + var;
    std::string varN = writeVar + "\n";
    printf(".> %s\n", var.c_str());
    fprintf(yyout, varN.c_str());
    addStatement(writeVar);
    }
  | CONTINUE {
    // printf("statement2 -> CONTINUE\n");
    }
  | BREAK {
    int currentLoop = loopCount - 1;
    std::string outputString = ":= endloop" + std::to_string(currentLoop);
    printf("%s\n", outputString.c_str());
    std::string outputStringN = outputString + '\n';
    fprintf(yyout, outputStringN.c_str());
    $$ = "break";
    // printf("statement2 -> BREAK\n");
    }
  | RETURN E {
    printf("ret %s\n", $2);
    std::string var = $2;
    std::string retSymbol = "ret " + var;
    addStatement(retSymbol);

    std::string retN = retSymbol + "\n";
    fprintf(yyout, retN.c_str());
    // printf("statement2 -> RETURN expression\n");
    };

ES: ELSE {int currentLoop = ifCount - 1;
    std::string outputString = ": else" + std::to_string(currentLoop);
    printf("%s\n", outputString.c_str());
    std::string outputN = outputString + "\n";
    fprintf(yyout, outputN.c_str()); } 
    S1 {
    
    // printf("else -> ELSE statements\n"); 
  }| {
    // printf("else -> epsilon\n"); 
  };
BE: N E C E {
  std::string ntString = $1;
  std::string e1 = $2;
  std::string c = $3;
  std::string e2 = $4;
  int currentLoop = loopCount - 1;


  std::string temp = "_temp" + std::to_string(tmpCount++);
  printf(". %s\n", temp.c_str());
  std::string tempN = ". " + temp + "\n";
  fprintf(yyout, tempN.c_str());

  std::string compOp = c + " " + temp + ", " + e1 + ", " + e2;
  printf("%s\n", compOp.c_str());
  std::string compOpN = compOp + "\n";
  fprintf(yyout, compOpN.c_str());

  std::string loopAssn = "?:= loopbody" + std::to_string(currentLoop) + ", " + temp;
  printf("%s\n", loopAssn.c_str());
  std::string loopAssnN = loopAssn + "\n";
  fprintf(yyout, loopAssnN.c_str());

  std::string endLoopS = ":= endloop" + std::to_string(currentLoop);
  printf("%s\n", endLoopS.c_str());
  std::string endLoopN = endLoopS + "\n";
  fprintf(yyout, endLoopN.c_str());

  /* std::string tempSymbol = ". " + temp;
  addStatement(tempSymbol); */

 // printf("bool_exp -> not expression comparison expression\n");
} 
| {
  // printf("bool_exp -> epsilon\n");
  $$ = "";
}; 

ifBE: N E C E {
  std::string ntString = $1;
  std::string e1 = $2;
  std::string c = $3;
  std::string e2 = $4;
  int currentLoop = ifCount - 1;


  std::string temp = "_temp" + std::to_string(tmpCount++);
  printf(". %s\n", temp.c_str());
  std::string tempN = ". " + temp + "\n";
  fprintf(yyout, tempN.c_str());

  std::string compOp = c + " " + temp + ", " + e1 + ", " + e2;
  printf("%s\n", compOp.c_str());
  std::string compOpN = compOp + "\n";
  fprintf(yyout, compOpN.c_str());

  std::string loopAssn = "?:= if_true" + std::to_string(currentLoop) + ", " + temp;
  printf("%s\n", loopAssn.c_str());
  std::string loopAssnN = loopAssn + "\n";
  fprintf(yyout, loopAssnN.c_str());

  std::string endLoopS = ":= else" + std::to_string(currentLoop);
  printf("%s\n", endLoopS.c_str());
  std::string endLoopN = endLoopS + "\n";
  fprintf(yyout, endLoopN.c_str());

  /* std::string tempSymbol = ". " + temp;
  addStatement(tempSymbol); */

 // printf("bool_exp -> not expression comparison expression\n");
} 
| {
  // printf("bool_exp -> epsilon\n");
  $$ = "";
}; 

N: NOT N {
  printf("not -> NOT not\n");
  std::string current = $$;
  std::string notString = current + " not";
  char* notC = strdup(notString.c_str());
  $$ = notC;
  } | {
    // printf("not -> epsilon\n");
    $$ = "";
    } ;
C: EQ { 
    // printf("comparison -> EQ\n"); 
    $$ = "=";
    }
  | NEQ {
    // printf("comparison -> NEQ\n"); 
    $$ = "!=";
    }
  | LT {
    // printf("comparison -> LT\n"); 
    $$ = "<";
    }
  | GT {
    // printf("comparison -> GT\n"); 
    $$ = ">";
    }
  | LTE {
    // printf("comparison -> LTE\n"); 
    $$ = "<=";
    }
  | GTE {
    // printf("comparison -> GTE\n");
    $$ = ">=";
    }; 
  
E: ME { $$ = $1; }
  | ME AOP ME {
     // printf("expression -> mult_exp add_term\n"); 
    std::string temp = "_temp" + std::to_string(tmpCount++);
    std::string me1 = $1;
    std::string aop = $2;
    std::string me2 = $3;
    printf(". %s\n", temp.c_str());
    std::string tempSymbol = ". " + temp;
    addStatement(tempSymbol);

    std::string tempN = tempSymbol + "\n";
    fprintf(yyout, tempN.c_str());

    printf("%s %s, %s, %s\n", aop.c_str(), temp.c_str(), me1.c_str(), me2.c_str());
    std::string outputSymbol = aop + " " + temp + ", " + me1 + ", " + me2;
    char* outputc = strdup(temp.c_str());
    $$ = outputc;
    addStatement(outputSymbol);

    std::string outputN = outputSymbol + "\n";
    fprintf(yyout, outputN.c_str());
  }
AOP: ADD { /* printf("add_op -> ADD\n"); */ $$ = "+"; }
  | SUB { /* printf("add_op -> SUB\n"); */ $$ = "-"; };
ME: T { std::string output = $1; /* printf("%s\n", output.c_str()); */ }
  | T MOP ME { 
    // printf("mult_exp -> term mult_term\n");
    std::string temp = "_temp" + std::to_string(tmpCount++);
    printf(". %s\n", temp.c_str());
    std::string tempSymbol = ". " + temp;
    addStatement(tempSymbol);

    std::string tempN = tempSymbol + "\n";
    fprintf(yyout, tempN.c_str());

    std::string moperator = $2;
    std::string lefthand = $1;
    std::string me = $3;
    std::string output = moperator + " " + temp + ", " + lefthand + ", " + me;
    printf("%s\n", output.c_str()); 
    addStatement(output);

    std::string outputN = output + "\n";
    fprintf(yyout, outputN.c_str());

    char* tempC = strdup(temp.c_str());
    $$ = tempC;
    };
MOP: MULT { 
    /* printf("mult_op -> MULT\n"); */ 
    $$ = "*"; 
    }
  |  DIV { 
    /* printf("mult_op -> DIV\n"); */ 
    $$ = "/"; 
    }
  |  MOD { 
    /* printf("mult_op -> MOD\n"); */ 
    $$ = "%"; 
    };
T: V { /* printf("term -> var\n"); */ $$ = $1; }
  | number {
    /*printf("term -> number %d\n", yylval);*/ 
    int num = $1; 
    std::string output = std::to_string(num); 
    char* outputc = strdup(output.c_str()); 
    $$ = outputc;  
    }
  | L_PAREN E R_PAREN {
    // printf("term -> L_PAREN expression R_PAREN\n"); 
    std::string e = $2; 
    std::string output = "(" + e + ")"; 
    char* outputc = strdup(e.c_str()); 
    $$ = outputc; }
  | identifier L_PAREN ECL R_PAREN {
    // printf("term -> identifier L_PAREN expression_comma_loop R_PAREN\n"); 
    std::string ident = $1;
    std::string ecl = $3;
    printf("call %s, %s\n", ident.c_str(), ecl.c_str());
    std::string callSymbol = "call " + ident + ", " + ecl;
    addStatement(callSymbol);

    std::string callN = callSymbol + "\n";
    fprintf(yyout, callN.c_str());

    $$ = $3; 
    }
ECL: E { printf("param %s\n", $1); 
std::string e = $1; 
std::string output = "param " + e; 
addStatement(output);
std::string outputN = output + "\n"; 
fprintf(yyout, outputN.c_str());
} 
COMMA ECL {
    // printf("expression_comma_loop -> expression COMMA expression_comma_loop\n"); 
    std::string e = $1;
    std::string ecl = $4;
    std::string output = e + "," + ecl;
    char* outputc = strdup(output.c_str());
    
    printf("param %s\n", $4);
    std::string paramSymbol = "param " + ecl;
    addStatement(paramSymbol);

    std::string paramN = paramSymbol + "\n";
    fprintf(yyout, paramN.c_str());

    std::string temp = "_temp" + std::to_string(tmpCount++);
    printf(". %s\n", temp.c_str());
    std::string tempSymbol = ". " + temp;
    addStatement(tempSymbol);

    std::string tempN = tempSymbol + "\n";
    fprintf(yyout, tempN.c_str());

    $$ = strdup(temp.c_str()); 
    }
  | E { /* printf("expression_comma_loop -> expression\n"); */ $$ = $1; }
  | { /* printf("expression_comma_loop -> epsilon\n"); */ $$ = ""; }; 
V: identifier { $$ = $1; }
  | identifier L_SQUARE_BRACKET E R_SQUARE_BRACKET { 
    //Node* node = new Node();
    std::string ident = $1;
    std::string e = $3;
    std::string outputString = "[]= " + ident + ", " + e; 
    char* outputC = strdup(outputString.c_str());

    std::string temp = "_temp" + std::to_string(tmpCount++);
    printf(". %s\n", temp.c_str());
    std::string tempSymbol = ". " + temp;
    addStatement(tempSymbol);

    std::string tempN = tempSymbol + "\n";
    fprintf(yyout, tempN.c_str());

    std::string output = "=[] " + temp + ", " + ident + ", " + e;
    printf("%s\n", output.c_str()); 
    addStatement(output);

    std::string outputN = output + "\n";
    fprintf(yyout, outputN.c_str());

    char* tempC = strdup(temp.c_str());
    $$ = tempC;
    }
identifier: IDENTIFIER { $$ = $1; }
number: NUMBER { $$ = $1; }
%%

int main(int argc, char **argv) {
   yyin = stdin;
   if (argc > 1){
      yyin = fopen(argv[1], "r");
   }

   yyout = fopen("output.mil", "w");

   yyparse();
   fclose(yyout);
   printSymbolTable();
   //printf("%s", argv[0]);

   return 0;
}

void yyerror(const char *msg) {
    printf("Syntax error at line %d: %s\n", yylloc.last_line, msg);
}


