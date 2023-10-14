%DEFINE SYS_MMAP 9
%DEFINE SYS_WRITE 1
%DEFINE SYS_EXIT 60

%DEFINE LEN 640 * 1024

global _start

segment .text

_start:
	; write
	lea rsi, [intro]
	mov rdx, intro_len
	call print_fun

	; mmap
	mov rax, SYS_MMAP
	mov rdi, 0
	mov rsi, LEN
	mov rdx, 0x3		; PROT_READ | PROT_WRITE
	mov r10, 0x22		; MAP_ANONYMOUS | MAP_PRIVATE
	; mov r8, 0
	; mov r9, 0
	syscall

	cmp rax, 0
	jl exit

	lea rsi, [success]
	mov rdx, success_len
	call print_fun

exit:
	call exit_fun
	
	ret

print_fun:
;; rsi = char* buf
;; rdx = int len

	; write
	mov rax, SYS_WRITE
	mov rdi, 1
	syscall

	ret

exit_fun:
	; exit
	mov rax, SYS_EXIT
	mov rdi, 0
	syscall

	ret

fibi_fun:
	ret

segment .data

intro: db "Hello, world!", 10
intro_len: equ $ - intro

success: db "Successfully, mmaped!", 10
success_len: equ $ - success
