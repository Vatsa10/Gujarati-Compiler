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
    const char *tacFilePath = "c:/Users/Admin/GujCompiler/tac.txt";
    FILE *tacFile = fopen(tacFilePath, "w");
    if (!tacFile) {
        printf("Error: Could not open file '%s' for writing TAC.\n", tacFilePath);
        perror("fopen");
        return;
    }

    printf("\nWriting Intermediate Code to file...\n");
    for (int i = 0; i < codeIndex; i++) {
        fprintf(tacFile, "%s\n", intermediateCode[i]);
    }
    fclose(tacFile);
    printf("TAC written to %s\n", tacFilePath);
    system("tac_to_asm.exe");
}

// Fully aligned TAC and assembly generation logic with parser[1].y

void generateAssemblyCode() {
    const char *tacFilePath = "c:/Users/Admin/GujCompiler/tac.txt";
    const char *asmFilePath = "c:/Users/Admin/GujCompiler/assembly.asm";

    // Write TAC to tac.txt
    FILE *tacFile = fopen(tacFilePath, "w");
    if (!tacFile) {
        printf("Error: Could not open file '%s' for writing TAC.\n", tacFilePath);
        perror("fopen");
        return;
    }

    for (int i = 0; i < codeIndex; i++) {
        fprintf(tacFile, "%s\n", intermediateCode[i]);
    }
    fclose(tacFile);
    printf("TAC written to %s\n", tacFilePath);
    system("tac_to_asm.exe");

    // Write Assembly to assembly.asm
    FILE *asmFile = fopen(asmFilePath, "w");
    if (!asmFile) {
        printf("Error: Could not open file '%s' for writing assembly code.\n", asmFilePath);
        perror("fopen");
        return;
    }
    
    // Write assembly header
    fprintf(asmFile, "; Generated x86 assembly from TAC\n");
    fprintf(asmFile, ".386\n");
    fprintf(asmFile, ".model flat, stdcall\n");
    fprintf(asmFile, ".stack 4096\n\n");
    fprintf(asmFile, ".data\n");
    fprintf(asmFile, "    ; Data section for variables\n");
    
    // Declare temporary variables in data section
    for (int i = 1; i <= tempCount; i++) {
        fprintf(asmFile, "    t%d DD 0\n", i);
    }
    
    fprintf(asmFile, "\n.code\n");
    fprintf(asmFile, "main PROC\n");

    for (int i = 0; i < codeIndex; i++) {
        char lhs[10], op1[10], op[5], op2[10];
        
        // Remove newline character if any
        char line[100];
        strcpy(line, intermediateCode[i]);
        line[strcspn(line, "\n")] = 0;
        
        fprintf(asmFile, "    ; %s\n", line); // Comment with original TAC
        
        // Handle assignment: t1 = 10
        if (sscanf(line, "%s = %s", lhs, op1) == 2 && !strstr(line, "+") && 
            !strstr(line, "-") && !strstr(line, "*") && !strstr(line, "/")) {
            // Check if op1 is a number or another variable
            if (op1[0] == 't') {
                fprintf(asmFile, "    MOV EAX, [%s]\n", op1);
            } else {
                fprintf(asmFile, "    MOV EAX, %s\n", op1);
            }
            fprintf(asmFile, "    MOV [%s], EAX\n", lhs);
        }
        // Handle binary operations: t3 = t1 + t2
        else if (sscanf(line, "%s = %s %s %s", lhs, op1, op, op2) == 4) {
            // Load first operand into EAX
            if (op1[0] == 't') {
                fprintf(asmFile, "    MOV EAX, [%s]\n", op1);
            } else {
                fprintf(asmFile, "    MOV EAX, %s\n", op1);
            }
            
            // Perform operation based on operator
            if (strcmp(op, "+") == 0) {
                if (op2[0] == 't') {
                    fprintf(asmFile, "    ADD EAX, [%s]\n", op2);
                } else {
                    fprintf(asmFile, "    ADD EAX, %s\n", op2);
                }
            } else if (strcmp(op, "-") == 0) {
                if (op2[0] == 't') {
                    fprintf(asmFile, "    SUB EAX, [%s]\n", op2);
                } else {
                    fprintf(asmFile, "    SUB EAX, %s\n", op2);
                }
            } else if (strcmp(op, "*") == 0) {
                if (op2[0] == 't') {
                    fprintf(asmFile, "    MOV EBX, [%s]\n", op2);
                    fprintf(asmFile, "    IMUL EAX, EBX\n");
                } else {
                    fprintf(asmFile, "    IMUL EAX, %s\n", op2);
                }
            } else if (strcmp(op, "/") == 0) {
                fprintf(asmFile, "    MOV EDX, 0\n"); // Clear EDX for division
                if (op2[0] == 't') {
                    fprintf(asmFile, "    MOV EBX, [%s]\n", op2);
                    fprintf(asmFile, "    DIV EBX\n");
                } else {
                    fprintf(asmFile, "    MOV EBX, %s\n", op2);
                    fprintf(asmFile, "    DIV EBX\n");
                }
            } else if (strcmp(op, "%") == 0) {
                fprintf(asmFile, "    MOV EDX, 0\n"); // Clear EDX for division
                if (op2[0] == 't') {
                    fprintf(asmFile, "    MOV EBX, [%s]\n", op2);
                    fprintf(asmFile, "    DIV EBX\n");
                    fprintf(asmFile, "    MOV EAX, EDX\n"); // Move remainder to EAX
                } else {
                    fprintf(asmFile, "    MOV EBX, %s\n", op2);
                    fprintf(asmFile, "    DIV EBX\n");
                    fprintf(asmFile, "    MOV EAX, EDX\n"); // Move remainder to EAX
                }
            }
            
            // Store result
            fprintf(asmFile, "    MOV [%s], EAX\n", lhs);
        }
        
        fprintf(asmFile, "\n");
    }

    // Cleanup and exit
    fprintf(asmFile, "    ; Cleanup and exit\n");
    fprintf(asmFile, "    MOV EAX, 0\n");
    fprintf(asmFile, "    RET\n");
    fprintf(asmFile, "main ENDP\n");
    fprintf(asmFile, "END main\n");

    fclose(asmFile);
    printf("Assembly code written to %s\n", asmFilePath);
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
