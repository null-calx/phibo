.PHONY: all
all: vuln

vuln: vuln.o
	ld -o vuln vuln.o

vuln.o: vuln.nasm
	nasm -o vuln.o -felf64 vuln.nasm

.PHONY: clean
clean:
	rm -rfv vuln vuln.o
