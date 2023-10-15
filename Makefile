.PHONY: all
all: phibo

phibo: phibo.o
	ld -o phibo phibo.o

phibo.o: phibo.nasm
	nasm -o phibo.o -felf64 phibo.nasm

.PHONY: clean
clean:
	rm -rfv phibo phibo.o
