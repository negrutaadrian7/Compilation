CC=gcc
YFLAG=-d 
PROGRAM=comp
OBJS=y.tab.o lex.yy.o
SRCS=y.tab.c lex.yy.c

all: $(PROGRAM)

.c.o: $(SRCS)
	$(CC) -c $*.c -o $@ -O


lex.yy.c: tokenC.l 
	flex tokenC.l


y.tab.c: miniC.y
	yacc $(YFLAG) miniC.y 

comp: $(OBJS)
	$(CC) $(OBJS) -o $@ -lm

clean:
	rm -f $(OBJS) core *~ \#* *.o $(PROGRAM) lex.yy.* y.tab.*
