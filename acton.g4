grammar acton;


SENDER: 'sender';
BREAK: 'break';
CONTINUE: 'continue';
IF: 'if';
ELSE: 'else';
FOR: 'for';
PRINT: 'print';
EXTENDS: 'extends';
ACTOR: 'actor';
MSGHANDLER: 'msghandler';
ACTORVARS: 'actorvars';
KNOWNACTORS: 'knownactors';
INIT: 'initial';
SELF: 'self';
MAIN: 'main';
INT: 'int';
BOOL: 'boolean';
STR: 'string';
TRUE: 'true';
FALSE : 'false';
QUESTION_MARK : '?';
LPAR: '(';
RPAR: ')';
LCBR: '{';
RCBR: '}';
LBRC: '[';
RBRC: ']';
SEMICOLON: ';';
COMMA: ',';
COLON: ':';
ASSIGN: '=';
DOT: '.';
DQUOTE: '"';

SUB: '-' ;
ADD: '+' ;
DIV: '/' ;
MULT: '*';
MOD : '%';
INC: '++';
DEC: '--';

EQUAL: '==' ;
NOTEQ: '!=' ;
GREATER_THAN: '>' ;
LESS_THAN: '<' ;
AND: '&&' ;
OR: '||' ;
NOT: '!' ;

CONST_NUM: ([0] | [1-9][0-9]*);
IDENTIFIER: LETTER (LETTER | CONST_NUM)*;
STRING_VALUE: DQUOTE ~('\n' | '\r' | '"')* DQUOTE;
WS: [ \t\r\n]+ -> skip;
LINE_COMMENT: '//' ~[\r\n]* -> skip;
LETTER: [a-zA-Z_];


program: (actor_declaration)* main_dec EOF;

actor_declaration :
  {System.out.print("ActorDec:");}
  ACTOR IDENTIFIER {System.out.print($IDENTIFIER.text);}
  ( EXTENDS IDENTIFIER {System.out.print("," + $IDENTIFIER.text);} )? {System.out.println();}
  LPAR CONST_NUM RPAR LCBR actor_body RCBR ;

actor_body :
     knownactor_declaration actorvars_declaration (initial_msghandler_declaration)? (msghandler_declaration)* ;

actor_object_dec  locals [String str = new String("");] :
    (actortype=IDENTIFIER
    actorname=IDENTIFIER
    {$str += ( "ActorInstantiation:" + $actortype.text + "," + $actorname.text);}
    LPAR
    (
        knownactor1=IDENTIFIER
        {$str += "," + $knownactor1.text;}
        (
            COMMA knownactor2=IDENTIFIER
            {$str += ("," + $knownactor2.text);}
        )*
    ) RPAR
    {System.out.println($str);}
    COLON
    LPAR (expression (COMMA(expression))*)? RPAR
    SEMICOLON)
;

knownactor_declaration:
    KNOWNACTORS LCBR
        (
            id1=IDENTIFIER
            id2=IDENTIFIER
            SEMICOLON
            {System.out.println("KnownActor:" + $id1.text + "," + $id2.text);}
        )*
    RCBR
;

actorvars_declaration:
  ACTORVARS LCBR (var_declaration_stmt)* RCBR ;

initial_msghandler_declaration:
    MSGHANDLER INIT {System.out.print("MsgHandlerDec:initial");}
    LPAR params_dec RPAR LCBR (stmts)* RCBR ;

msghandler_declaration:
    MSGHANDLER IDENTIFIER {System.out.print("MsgHandlerDec:" + $IDENTIFIER.text);}
    LPAR params_dec RPAR LCBR (stmts)* RCBR ;

params_dec :
        ((INT | STR | INT LBRC CONST_NUM RBRC | BOOL) IDENTIFIER
        {System.out.print("," + $IDENTIFIER.text);}
        (
            COMMA
            (INT | STR | INT LBRC CONST_NUM RBRC | BOOL) IDENTIFIER
            {System.out.print("," + $IDENTIFIER.text);}
        )*
    )?
    {System.out.print("\n");} ;

params :
    ((expression ) (COMMA (expression))*)? ;

int_dec :
    INT IDENTIFIER {System.out.println("VarDec:int," + $IDENTIFIER.text);} ;
string_dec:
    STR IDENTIFIER {System.out.println("VarDec:string," + $IDENTIFIER.text);} ;
boolean_dec :
    BOOL IDENTIFIER {System.out.println("VarDec:boolean," + $IDENTIFIER.text);} ;
int_arr_dec :
    INT IDENTIFIER LBRC CONST_NUM RBRC {System.out.println("VarDec:int[]," + $IDENTIFIER.text);} ;

main_dec:
    MAIN LCBR (main_stmt)* RCBR ;

main_scope_stmt:
    LCBR main_stmt* RCBR ;

main_stmt:
     main_scope_stmt | actor_object_dec;

break_stmt :
    BREAK SEMICOLON ;

continue_stmt :
    CONTINUE SEMICOLON ;

print_stmt :
    {System.out.println("Built-in:Print");}
    PRINT LPAR (expression) RPAR SEMICOLON ;

dec_stmt:
    IDENTIFIER DEC ;

inc_stmt:
    IDENTIFIER INC ;

assign_stmt :
    (IDENTIFIER |  IDENTIFIER LBRC (CONST_NUM) RBRC) ASSIGN expression ;


method_call_stmt:
    actorname = IDENTIFIER DOT handlername = IDENTIFIER LPAR
    {System.out.println("MsgHandlerCall:" + $actorname.text + "," + $handlername.text);}
    params RPAR SEMICOLON ;

self_call_stmt:
    SELF DOT id=IDENTIFIER
    {System.out.println("MsgHandlerCall:" + "self" + "," + $id.text);}
    LPAR params RPAR SEMICOLON ;

sender_call_stmt:
    SENDER DOT id=IDENTIFIER
    {System.out.println("  MsgHandlerCall:" + "sender" + "," + $id.text);}
    LPAR params RPAR SEMICOLON ;

var_declaration_stmt :
   (int_dec | boolean_dec |  string_dec |  int_arr_dec) SEMICOLON ;

scope_stmt:
    LCBR stmts* RCBR ;

for_stmt:
    {System.out.println("Loop:for");}
    FOR LPAR
    ((assign_stmt)? SEMICOLON (expression)? SEMICOLON (inc_stmt | dec_stmt | assign_stmt)?) RPAR stmts ;

if_stmt:
    {System.out.println("Conditional:if");}
    IF LPAR (expression) RPAR (stmts else_stmt | stmts ) ;

else_stmt:
    {System.out.println("Conditional:else");}
    ELSE stmts ;


stmts :
        print_stmt | self_call_stmt | sender_call_stmt | method_call_stmt | dec_stmt SEMICOLON
        | inc_stmt SEMICOLON | assign_stmt SEMICOLON | for_stmt | scope_stmt  | break_stmt | continue_stmt
        | var_declaration_stmt  | if_stmt ;


expression: expression00 | ternaryExpression;
expression00 : expression0 | {System.out.print("Operator:=\n");} assign_stmt;
expression0 : expression1 | {System.out.print("Operator:||\n");} expression1 OR expression0;
expression1 : expression2 | {System.out.print("Operator:&&\n");} expression2 AND expression1;
expression2 : expression3 | {System.out.print("Operator:==\n");} expression3 EQUAL expression2 |
               {System.out.print("Operator:!=\n");} expression3 NOTEQ expression2;
expression3 : expression4 | {System.out.print("Operator:<\n");} expression4 GREATER_THAN expression3 |
               {System.out.print("Operator:>\n");} expression4 LESS_THAN expression3;
expression4 : {System.out.print("Operator:+\n");} expression5 ADD expression4 |
               {System.out.print("Operator:-\n");} expression5 SUB expression4 | expression5;
expression5 : expression6 | {System.out.print("Operator:*\n");} expression6 MULT expression5 |
               {System.out.print("Operator:/\n");} expression6 DIV expression5 | {System.out.print("Operator:%\n");}
               expression6 MOD expression5;
expression6 : expression7 | {System.out.print("Operator:--\n");} INC expression7 |
               {System.out.print("Operator:++\n");} DEC expression7 | {System.out.print("Operator:!\n");}
               NOT expression7 | {System.out.print("Operator:-\n");} SUB expression7;
expression7 : {System.out.print("Operator:++\n");} expression8 INC |
               {System.out.print("Operator:--\n");} expression8 DEC | expression8;
expression8 : expression9 | LPAR (expression00) RPAR;
expression9 : SENDER |  (SELF DOT IDENTIFIER) | INT LBRC expression RBRC IDENTIFIER | IDENTIFIER | TRUE | FALSE | STRING_VALUE | CONST_NUM;

ternaryExpression :  (((LPAR ternaryExpression RPAR) | expression00 )
                QUESTION_MARK {System.out.print("Operator:?:\n");} (expression) COLON (expression)) |
                (LPAR ternaryExpression RPAR);
