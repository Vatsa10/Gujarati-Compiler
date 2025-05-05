### Command to run:
```
flex flex.l
```
```
bison -dy yacc.y
```
```
gcc -w lex.yy.c y.tab.c -o some.exe
```
./tac_to_asm.exe

### Example input:

chhapi mar hi

chhapi mar 5+2

Chhapi mar (5+2)*7

Chappi mar 3+4*3

jo (5==2+3) to chhapi mar barrabar

jo(32>=23 ane 5!= 4) to chhapi mar ok baki chhapi mar bye
