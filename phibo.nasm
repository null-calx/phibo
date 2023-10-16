;;;; Simple program to print Fibonacci Sequence using MMAPed buffer

;; (rax rdi rsi rdx r10 r8 r9) used for making syscall
;; (rax) for syscall return values

;; (rbx) for base address of buffer
;; (rcx) for counter
;; (r8b r9b) for fibonacci calculations

;; (r15) for base address of print buffer
;; (r14 rdi) for printing counter
;; (rsi rax rdx) for division and printing calculations

%DEFINE SYS_WRITE 1
%DEFINE SYS_MMAP 9
%DEFINE SYS_MUNMAP 11
%DEFINE SYS_EXIT 60

%DEFINE LEN 384
%DEFINE PLEN 3

segment .text

global _start
_start:
	; print hello
	lea rsi, [hello]
	mov rdx, hello_len
	call print

	; mmap syscall
	mov rax, SYS_MMAP
	xor rdi, rdi
	mov rsi, LEN + PLEN
	mov rdx, 0x3		; PROT_READ | PROT_WRITE
	mov r10, 0x22		; MAP_ANONYMOUS | MAP_PRIVATE
	; xor r8, r8
	; xor r9, r9
	syscall

	; success check
	cmp rax, 0
	jl done

	; save buffer
	mov rbx, rax		; save memory buffer
	mov r15, rax
	add r15, LEN		; save print buffer

	; print success
	lea rsi, [success]
	mov rdx, success_len
	call print

	; setup for fibonacci calculation
	xor rcx, rcx
	mov byte [rbx + rcx], 0
	push rcx
	call print_number
	pop rcx
	inc rcx
	mov byte [rbx + rcx], 1
	push rcx
	call print_number
	pop rcx
	inc rcx

loop:
	; main loop
	push rcx
	call fibonacci
	pop rcx
	inc rcx
	cmp rcx, LEN
	jl loop

	; print newline
	mov byte [r15], 10
	mov rsi, r15
	mov rdx, 1
	call print

	; munmap
	mov rax, SYS_MUNMAP
	mov rdi, rbx
	mov rsi, LEN + PLEN
	syscall

done:
	; done
	call exit

	ret

print:
	; (rsi = char* buf, rdx = int len)
	; write syscall
	mov rax, SYS_WRITE
	mov rdi, 1		; STDOUT
	syscall

	ret

exit:
	; exit syscall
	mov rax, SYS_EXIT
	mov rdi, 0
	syscall

	ret

fibonacci:
	; F(n) = F(n - 1) + F(n - 2)
	mov r8b, [rbx + rcx - 2]
	mov r9b, [rbx + rcx - 1]
	add r8b, r9b
	mov [rbx + rcx], r8b

	call print_number

	ret

;; this is sh*t, but works
print_number:
	; print the number in [rbx + rcx]
	xor rax, rax
	xor rdx, rdx
	mov al, [rbx + rcx]
	mov rdi, 0
	dec rdi
	mov r14, 0
	mov rsi, 10
next_digit:
	div sil
	mov dl, ah
	xor ah, ah
	add dl, '0'
	mov byte [r15 + rdi + PLEN], dl
	dec rdi
	inc r14
	cmp rax, 0
	jne next_digit

	; print it
	mov rsi, PLEN
	add rsi, r15
	add rsi, rdi
	inc rsi
	mov rdx, r14
	call print

	mov byte [r15], ' '
	mov rsi, r15
	mov rdx, 1
	call print
	
	ret

segment .data

hello: db "Hello, world!", 10
hello_len: equ $ - hello

success: db "Successfully MMAPed memory!", 10
success_len: equ $ - success
