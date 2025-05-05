%{
#include<stdio.h>
#include<conio.h>
#include<stdlib.h>
#include<string.h>

int flag=0;
int tempCount = 0; // Counter for temporary variables
char intermediateCode[1000][100]; // Array to store intermediate code
int codeIndex = 0; // Index for intermediate code array
int tempValues[1000]; // Array to store computed values of temporary variables

// Added debug statements to verify TAC generation and assembly code processing

void addIntermediateCode(const char *code) {
    strcpy(intermediateCode[codeIndex++], code);
    printf("[DEBUG] TAC Added: %s\n", code); // Debug: Print each TAC as it is added
}

void printIntermediateCode() {
    printf("\nIntermediate Code:\n");
    for (int i = 0; i < codeIndex; i++) {
        printf("%s\n", intermediateCode[i]);
    }
}

// Updated assembly generation to handle TAC

void generateAssemblyCode() {
    const char *filePath = "c:/Users/Admin/GujCompiler/assembly_output.txt";
    FILE *file = fopen(filePath, "w");
    if (!file) {
        printf("Error: Could not open file '%s' for writing assembly code.\n", filePath);
        perror("fopen");
        return;
    }

    printf("\nAssembly Code:\n");
    for (int i = 0; i < codeIndex; i++) {
        char *tac = intermediateCode[i];
        char assembly[100];

        printf("[DEBUG] Processing TAC: %s\n", tac);

        if (strstr(tac, "=") != NULL) {
            char lhs[10], op1[10], op[10], op2[10];
            int parsed = sscanf(tac, "%s = %s %s %s", lhs, op1, op, op2);

            if (parsed == 4) {
                if (strcmp(op, "+") == 0) {
                    sprintf(assembly, "LOAD %s\nADD %s\nSTORE %s", op1, op2, lhs);
                } else if (strcmp(op, "-") == 0) {
                    sprintf(assembly, "LOAD %s\nSUB %s\nSTORE %s", op1, op2, lhs);
                } else if (strcmp(op, "*") == 0) {
                    sprintf(assembly, "LOAD %s\nMUL %s\nSTORE %s", op1, op2, lhs);
                } else if (strcmp(op, "/") == 0) {
                    sprintf(assembly, "LOAD %s\nDIV %s\nSTORE %s", op1, op2, lhs);
                } else if (strcmp(op, "%") == 0) {
                    sprintf(assembly, "LOAD %s\nMOD %s\nSTORE %s", op1, op2, lhs);
                }
            } else if (parsed == 2) {
                sscanf(tac, "%s = %s", lhs, op1);
                sprintf(assembly, "LOAD %s\nSTORE %s", op1, lhs);
            }

            fprintf(file, "%s\n", assembly);
            printf("%s\n", assembly);
        }
    }

    fclose(file);
    printf("Assembly code written to %s\n", filePath);
}
%}

%token NUMBER PRINT WHITESPACE NEWLINE EXIT HELP STRING OBRACE CBRACE
%token IF THEN ELSE GT LT EQ GE LE NE AND OR EXOR ADD SUB MUL DIV MOD ANDAND OROR
%left ADD SUB
%left MUL DIV MOD
%left  OBRACE CBRACE
%%

COMMAND: {printf("$ ");} Expression1 ;

Expression1: errorPrint
            | exit
            | printString 
            | printNumber
            | help
            | ifCondition 
            | ifElseCondition 
            | E 
            ;

errorPrint: STRING NEWLINE 
        {
            printf("Amanya aadesh.Madad mate '--madad' vapro.\n\n");
        } COMMAND;

exit: EXIT NEWLINE 
        {
            printf("\nPacha avjo.\n");
            printIntermediateCode(); // Print intermediate code before exiting
            generateAssemblyCode(); // Generate and print assembly code
            exit(0);
        };

printString: PRINT WHITESPACE STRING NEWLINE 
                                        {
                                            printf("%s",$3);
                                        } COMMAND;

printNumber: PRINT WHITESPACE E NEWLINE {
    printf("%d\n", tempValues[$3]);
    printIntermediateCode(); // Print intermediate code after evaluation
} COMMAND;

ifCondition: IF OBRACE CONDITION CBRACE THEN Expression1 NEWLINE {
    if ($3) {
        printf("%d\n", $6);
    } else {
        printf("Sachu to nakh.\n");
    }
} COMMAND;

ifElseCondition: IF OBRACE CONDITION CBRACE THEN Expression1 ELSE Expression1 NEWLINE {
    if ($3) {
        printf("Sachi sarat ganya baad : %d\n", $6);
    } else {
        printf("Khoti sarat ganya baad : %d\n", $8);
    }
} COMMAND;

help: HELP NEWLINE
                { 
                    printf("chhapva mate\t:\tchhapi mar string | chhapi mar expression\n");
                    printf("expression\t:\tnum+num || num-num || num*num || num/num || num%cnum || num&num || num|num || num^num || (Expression)\n",'%');
                    printf("jo\t\t:\tjo(condition) to expression\n"); 
                    printf("jo-to-baki\t:\tjo(condition) to expression baki expression\n");
                    printf("madad\t\t:\t--madad\n");
                    printf("bandh krva mate\t:\tEND\n");
                } COMMAND;

E:E ADD E {
    char temp[20];
    sprintf(temp, "t%d = t%d + t%d", ++tempCount, $1, $3);
    addIntermediateCode(temp);
    $$ = tempCount; // Store the result in the current tempCount
    tempValues[tempCount] = tempValues[$1] + tempValues[$3]; // Compute the result
}
|E SUB E {
    char temp[20];
    sprintf(temp, "t%d = t%d - t%d", ++tempCount, $1, $3);
    addIntermediateCode(temp);
    $$ = tempCount;
    tempValues[tempCount] = tempValues[$1] - tempValues[$3];
}
|E MUL E {
    char temp[20];
    sprintf(temp, "t%d = t%d * t%d", ++tempCount, $1, $3);
    addIntermediateCode(temp);
    $$ = tempCount;
    tempValues[tempCount] = tempValues[$1] * tempValues[$3];
}
|E DIV E {
    char temp[20];
    sprintf(temp, "t%d = t%d / t%d", ++tempCount, $1, $3);
    addIntermediateCode(temp);
    $$ = tempCount;
    tempValues[tempCount] = tempValues[$1] / tempValues[$3];
}
|E MOD E {
    char temp[20];
    sprintf(temp, "t%d = t%d %% t%d", ++tempCount, $1, $3);
    addIntermediateCode(temp);
    $$ = tempCount;
    tempValues[tempCount] = tempValues[$1] % tempValues[$3];
}
|OBRACE E CBRACE {
    $$ = $2; // Propagate the value inside parentheses
}
| NUMBER {
    char temp[20];
    sprintf(temp, "t%d = %d", ++tempCount, $1);
    addIntermediateCode(temp);
    $$ = tempCount;
    tempValues[tempCount] = $1; // Store the value of the number
};

CONDITION:E GT E {
    char temp[20];
    sprintf(temp, "t%d = t%d > t%d", ++tempCount, $1, $3);
    addIntermediateCode(temp);
    $$ = tempCount;
}
|   E LT E {
    char temp[20];
    sprintf(temp, "t%d = t%d < t%d", ++tempCount, $1, $3);
    addIntermediateCode(temp);
    $$ = tempCount;
}
|   E EQ E {
    char temp[20];
    sprintf(temp, "t%d = t%d == t%d", ++tempCount, $1, $3);
    addIntermediateCode(temp);
    $$ = tempCount;
}
|   E GE E {
    char temp[20];
    sprintf(temp, "t%d = t%d >= t%d", ++tempCount, $1, $3);
    addIntermediateCode(temp);
    $$ = tempCount;
}
|   E LE E {
    char temp[20];
    sprintf(temp, "t%d = t%d <= t%d", ++tempCount, $1, $3);
    addIntermediateCode(temp);
    $$ = tempCount;
}
|   E NE E {
    char temp[20];
    sprintf(temp, "t%d = t%d != t%d", ++tempCount, $1, $3);
    addIntermediateCode(temp);
    $$ = tempCount;
}
|   CONDITION ANDAND CONDITION {
    char temp[20];
    sprintf(temp, "t%d = t%d && t%d", ++tempCount, $1, $3);
    addIntermediateCode(temp);
    $$ = tempCount;
}
|   CONDITION OROR CONDITION {
    char temp[20];
    sprintf(temp, "t%d = t%d || t%d", ++tempCount, $1, $3);
    addIntermediateCode(temp);
    $$ = tempCount;
}
|   E {
    $$ = $1;
}
;

%%

void main()
{
    printf("\nCompiler ma tamaru SWAGAT che.\n\nSTART\n");
    yyparse();
    getch();
}

void yyerror()
{
   yyparse();
}
