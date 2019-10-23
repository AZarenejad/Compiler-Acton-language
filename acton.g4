grammar acton;


COMMA:
   ','
    ;

COLON:
   ':'
    ;

LPARENTHESIS:
   '('
    ;
RPARANTHESIS:
   ')'
    ;

RBRACE:
   '}'
    ;

LBRACE:
   '{'
    ;

ACTOR:
    'actor'
    ;

SELF:
   'self'
    ;
FALSE:
   'false'
    ;
KNOWNACTORS:
   'knownactors'
    ;
SENDER:
   'sender'
    ;
TRUE:
   'true'
    ;
IF:
   'if'
    ;
INT:
   'int'
    ;
ACTORVARS:
   'actorvars'
    ;
EXTENDS:
   'extends'
    ;
ELSE:
   'else'
    ;
BOOLEAN:
   'boolean'
    ;
INITIAL:
   'initial'
    ;
FOR:
   'for'
    ;

STRING:
   'string'
    ;
BREAK:
   'break'
    ;
MSGHANDLER:
   'msghandler'
    ;
PRINT:
   'print'
    ;
MAIN:
   'main'
    ;
CONTINUE:
   'continue'
    ;

SEMICOLON:
    ';'
    ;

CONST_NUM:
   [0-9]+
	;

CONST_STR:
   '"' ~('\r' | '\n' | '"')* '"'
	;

IDENTIFIER:
   [A-Za-z_][A-Za-z0-9_]*
    ;

WS:
   [ \t\r\n]+ -> skip
    ;






actorDeclaration:
    ACTOR IDENTIFIER (EXTENDS IDENTIFIER)? LPARENTHESIS CONST_NUM RPARANTHESIS LBRACE actorBody RBRACE
    ;

actorBody:
    knownActors  actorVars msgHandler
    ;

knownActors:
    KNOWNACTORS LBRACE (IDENTIFIER IDENTIFIER SEMICOLON)* RBRACE
    ;

actorVars:
    ACTORVARS LBRACE RBRACE
;

msgHandler:
    ;



statements:
        (statement)*
    ;

statement:
        statementBlock |
        statementCondition |
        statementLoop |
        statementAssignment
    ;

statementBlock:
        LBRACE  statements RBRACE
    ;
