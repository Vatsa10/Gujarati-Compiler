#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Function to parse TAC and generate assembly code
void generateAssembly(const char* tacFile, const char* asmFile) {
    FILE *inFile = fopen(tacFile, "r");
    FILE *outFile = fopen(asmFile, "w");
    
    if (!inFile) {
        printf("Error: Could not open TAC file %s\n", tacFile);
        return;
    }
    
    if (!outFile) {
        printf("Error: Could not open assembly output file %s\n", asmFile);
        fclose(inFile);
        return;
    }
    
    // Write assembly header
    fprintf(outFile, "; Generated x86 assembly from TAC\n");
    fprintf(outFile, ".386\n");
    fprintf(outFile, ".model flat, stdcall\n");
    fprintf(outFile, ".stack 4096\n\n");
    fprintf(outFile, ".data\n");
    fprintf(outFile, "    ; Data section for variables\n");
    
    // Count temporary variables to allocate space
    char line[256];
    int maxTempVar = 0;
    int tempNum;
    
    // First pass: find the highest temp variable number
    while (fgets(line, sizeof(line), inFile)) {
        if (line[0] == 't' && sscanf(line, "t%d", &tempNum) == 1) {
            if (tempNum > maxTempVar) {
                maxTempVar = tempNum;
            }
        }
    }
    
    // Declare temporary variables in data section
    for (int i = 1; i <= maxTempVar; i++) {
        fprintf(outFile, "    t%d DD 0\n", i);
    }
    
    fprintf(outFile, "\n.code\n");
    fprintf(outFile, "main PROC\n");
    
    // Reset file pointer to beginning for second pass
    rewind(inFile);
    
    // Second pass: generate assembly instructions
    while (fgets(line, sizeof(line), inFile)) {
        // Remove newline character
        line[strcspn(line, "\n")] = 0;
        
        fprintf(outFile, "    ; %s\n", line); // Comment with original TAC
        
        char lhs[10], op1[10], op[5], op2[10];
        
        // Handle assignment: t1 = 10
        if (sscanf(line, "%s = %s", lhs, op1) == 2 && !strstr(line, "+") && 
            !strstr(line, "-") && !strstr(line, "*") && !strstr(line, "/")) {
            // Check if op1 is a number or another variable
            if (op1[0] == 't') {
                fprintf(outFile, "    MOV EAX, [%s]\n", op1);
                fprintf(outFile, "    MOV [%s], EAX\n", lhs);
            } else {
                fprintf(outFile, "    MOV [%s], %s\n", lhs, op1);
            }
        }
        // Handle binary operations: t3 = t1 + t2
        else if (sscanf(line, "%s = %s %s %s", lhs, op1, op, op2) == 4) {
            // Load first operand into EAX
            if (op1[0] == 't') {
                fprintf(outFile, "    MOV EAX, [%s]\n", op1);
            } else {
                fprintf(outFile, "    MOV EAX, %s\n", op1);
            }
            
            // Perform operation based on operator
            if (strcmp(op, "+") == 0) {
                if (op2[0] == 't') {
                    fprintf(outFile, "    ADD EAX, [%s]\n", op2);
                } else {
                    fprintf(outFile, "    ADD EAX, %s\n", op2);
                }
            } else if (strcmp(op, "-") == 0) {
                if (op2[0] == 't') {
                    fprintf(outFile, "    SUB EAX, [%s]\n", op2);
                } else {
                    fprintf(outFile, "    SUB EAX, %s\n", op2);
                }
            } else if (strcmp(op, "*") == 0) {
                if (op2[0] == 't') {
                    fprintf(outFile, "    MOV EBX, [%s]\n", op2);
                    fprintf(outFile, "    IMUL EAX, EBX\n");
                } else {
                    fprintf(outFile, "    IMUL EAX, %s\n", op2);
                }
            } else if (strcmp(op, "/") == 0) {
                fprintf(outFile, "    MOV EDX, 0\n"); // Clear EDX for division
                if (op2[0] == 't') {
                    fprintf(outFile, "    MOV EBX, [%s]\n", op2);
                    fprintf(outFile, "    DIV EBX\n");
                } else {
                    fprintf(outFile, "    MOV EBX, %s\n", op2);
                    fprintf(outFile, "    DIV EBX\n");
                }
            }
            
            // Store result
            fprintf(outFile, "    MOV [%s], EAX\n", lhs);
        }
        
        fprintf(outFile, "\n");
    }
    
    // Add exit code
    fprintf(outFile, "    ; Exit program\n");
    fprintf(outFile, "    MOV EAX, 0\n");
    fprintf(outFile, "    RET\n");
    fprintf(outFile, "main ENDP\n");
    fprintf(outFile, "END main\n");
    
    fclose(inFile);
    fclose(outFile);
    printf("Assembly code generated successfully in %s\n", asmFile);
}

int main() {
    const char* tacFile = "c:\\Users\\Admin\\GujCompiler\\tac.txt";
    const char* asmFile = "c:\\Users\\Admin\\GujCompiler\\assembly.asm";
    
    generateAssembly(tacFile, asmFile);
    
    return 0;
}