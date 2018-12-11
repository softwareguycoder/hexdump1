hexdump1: hexdump1.o
	ld -o hexdump1 hexdump1.o
hexdump1.o: hexdump1.asm
	nasm -f elf64 -g -F stabs hexdump1.asm -l hexdump1.lst
clean:
	rm -f *.o *.lst hexdump1
