CC=gcc
ASMBIN=nasm

all : asm cc link

asm : bresenham_operations.asm
	$(ASMBIN) -o bresenham_operations.o -f elf -g -F dwarf bresenham_operations.asm

cc : image.h image.c image_test.c
	$(CC) -m32 -c -g -O0 image.c
	$(CC) -m32 -c -g -O0 image_test.c

link : image_test.o image.o bresenham_operations.o
	$(CC) -m32 -g -o dline image_test.o image.o bresenham_operations.o

clean :
	rm *.o
	rm dline
