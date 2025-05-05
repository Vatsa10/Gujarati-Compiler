; Generated x86 assembly from TAC
.386
.model flat, stdcall
.stack 4096

.data
    ; Data section for variables
    t1 DD 0
    t2 DD 0
    t3 DD 0

.code
main PROC
    ; t1 = 5
    MOV [t1], 5

    ; t2 = 2
    MOV [t2], 2

    ; t3 = t1 + t2
    MOV EAX, [t1]
    ADD EAX, [t2]
    MOV [t3], EAX

    ; Exit program
    MOV EAX, 0
    RET
main ENDP
END main
