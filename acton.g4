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

NUMBER_VALUE: ([0] | [1-9][0-9]*);
ID: LETTER (LETTER | NUMBER_VALUE)*;
STRING_VALUE: DQUOTE ~('\n' | '\r' | '"')* DQUOTE;
WS: [ \t\r\n]+ -> skip;
LINE_COMMENT: '//' ~[\r\n]* -> skip;
LETTER: [a-zA-Z_];




program: (actor_dec)* main_dec EOF;

actor_dec locals[ String print_str = new String(""); ]:
  {$actor_dec::print_str += "ActorDec:";}
  ACTOR ID
  {$actor_dec::print_str += $ID.text;}
  (
      EXTENDS ID
      {$actor_dec::print_str += ","+$ID.text;}
  )?
  {System.out.println($actor_dec::print_str);}
  LPAR NUMBER_VALUE RPAR
  LCBR
    actor_body
  RCBR
;


actor_body :
     knownactor_dec
     actorvars_dec
     (initial_msghandler_dec)?
     (msghandler_dec)* ;


actor_object_dec  locals [String str = new String("");] :
    (actortype=ID
    actorname=ID
    {$str += ( "ActorInstantiation:" + $actortype.text + "," + $actorname.text);}
    LPAR
    (
        knownactor1=ID
        {$str += "," + $knownactor1.text;}
        (
            COMMA knownactor2=ID
            {$str += ("," + $knownactor2.text);}
        )*
    ) RPAR
    {System.out.println($str);}
    COLON
    LPAR (expression (COMMA(expression))*)? RPAR
    SEMICOLON)
;

knownactor_dec:
    KNOWNACTORS
    LCBR
        (
            id1=ID
            id2=ID
            SEMICOLON
            {System.out.println("KnownActor:" + $id1.text + "," + $id2.text);}
        )*
    RCBR
;

actorvars_dec:
  ACTORVARS
  LCBR
      (
        var_dec_stmt
      )*
  RCBR
;

initial_msghandler_dec:
    MSGHANDLER INIT {System.out.print("MsgHandler:initial");}
    LPAR params_dec RPAR
    LCBR
        (msg_handler_stmts)*
    RCBR
;

msghandler_dec:
    MSGHANDLER ID
    {System.out.print("MsgHandler:" + $ID.text);}
    LPAR params_dec RPAR

    LCBR
        (msg_handler_stmts)*
    RCBR
;

params_dec :
        ((INT | STRING | INT LBRC NUMBER_VALUE RBRC | BOOL) ID
        {System.out.print("," + $ID.text);}
        (
            COMMA
            (INT | STRING | INT LBRC NUMBER_VALUE RBRC | BOOL) ID
            {System.out.print("," + $ID.text);}
        )*
    )?
    {System.out.print("\n");}
    ;
params :
    ((expression )
    (COMMA (expression))*)?
;


type_dec :
        int_dec | boolean_dec |  string_dec |  int_arr_dec ;


int_dec :

    INT ID
    {System.out.println("VarDec:int," + $ID.text);}
    ;
string_dec:

    STR ID
    {System.out.println("VarDec:string," + $ID.text);}
    ;
boolean_dec :

    BOOL ID
    {System.out.println("VarDec:boolean," + $ID.text);}
    ;
int_arr_dec :

    INT ID LBRC NUMBER_VALUE RBRC
     {System.out.println("VarDec:int[]," + $ID.text);}
    ;

main_dec:
    MAIN LCBR (main_stmt)* RCBR ;

main_scope_stmt:
    LCBR main_stmt* RCBR
;

main_stmt:
     main_scope_stmt | actor_object_dec
;



break_stmt :
    BREAK SEMICOLON
;

continue_stmt :
    CONTINUE SEMICOLON
;

print_stmt :
    {System.out.println("Built-in:Print");}
    PRINT LPAR (expression) RPAR SEMICOLON
;

dec_stmt:
    ID DEC
;


inc_stmt:
    ID INC
;

assign_stmt :
    (ID |  ID LBRC (NUMBER_VALUE) RBRC) ASSIGN expression
;




method_call_stmt:
    actorname = ID DOT handlername = ID LPAR
    {System.out.println("MsgHandlerCall:" + $actorname.text + "," + $handlername.text);}
    params RPAR SEMICOLON
;

self_call_stmt:
    SELF DOT id=ID
    {System.out.println("MsgHandlerCall:" + "self" + "," + $id.text);}
    LPAR params RPAR SEMICOLON
;

sender_call_stmt:

    SENDER DOT id=ID
    {System.out.println("  MsgHandlerCall:" + "sender" + "," + $id.text);}
    LPAR params RPAR SEMICOLON
;

var_dec_stmt :
    vars=type_dec SEMICOLON
//    {System.out.println("VarDec:" + $vars.text);}
;

scope_stmt:
    LCBR stmts* RCBR
;

for_stmt:
    {System.out.println("Loop:for");}
    FOR LPAR
    ((assign_stmt)? SEMICOLON
    (expression)? SEMICOLON
    (inc_stmt | dec_stmt | assign_stmt)?) RPAR stmts
;




if_stmt:
    {System.out.println("Conditional:if");}
    IF LPAR (expression) RPAR (stmts else_stmt | stmts )
;

else_stmt:
    {System.out.println("Conditional:else");}
    ELSE stmts
;

msg_handler_if_stmt:
    {System.out.println("Conditional:if");}
    IF LPAR (expression) RPAR (msg_handler_stmts msg_handler_else_stmt | msg_handler_stmts)
;

msg_handler_else_stmt:
    {System.out.println("Conditional:else");}
    ELSE msg_handler_stmts
;


//if_stmt :
//      matched_if_stmt
//    | unmatched_if_stmt
//;
//
//matched_if_stmt:
//    IF {System.out.println("Conditional:if ");} LPAR expressions RPAR matched_if_stmt ELSE  {System.out.println("Conditional:else ");} matched_if_stmt
//;
//
//unmatched_if_stmt:
//      IF  {System.out.println("Conditional:if ");} LPAR expressions RPAR stmts
//    | IF  {System.out.println("Conditional:if ");} LPAR expressions RPAR matched_if_stmt ELSE  {System.out.println("Conditional:else ");} unmatched_if_stmt
//;








stmts :
         print_stmt | method_call_stmt | dec_stmt SEMICOLON  | inc_stmt SEMICOLON| assign_stmt SEMICOLON |  for_stmt
        | scope_stmt | break_stmt | continue_stmt | var_dec_stmt | if_stmt
;

msg_handler_stmts :

          print_stmt | self_call_stmt | sender_call_stmt | method_call_stmt | dec_stmt SEMICOLON
        | inc_stmt SEMICOLON | assign_stmt SEMICOLON | for_stmt | scope_stmt  | break_stmt | continue_stmt
        | var_dec_stmt  | msg_handler_if_stmt
;





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
expression9 : SENDER |  (SELF DOT ID) | INT LBRC NUMBER_VALUE RBRC ID | ID | TRUE | FALSE | STRING_VALUE | NUMBER_VALUE;

ternaryExpression :  (((LPAR ternaryExpression RPAR) | expression00 )
                QUESTION_MARK {System.out.print("Operator:?:\n");} (expression) COLON (expression)) |
                (LPAR ternaryExpression RPAR);
