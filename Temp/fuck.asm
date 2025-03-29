section .data
    msg db 'A'     ; Define the character to print

section .text
    global _start  ; Make the _start label visible to the linker

_start:
    ; Write the character to standard output (stdout)
    mov rax, 1      ; syscall number for sys_write (1)
    mov rdi, 1      ; file descriptor 1 is stdout
    mov rsi, msg    ; address of the message
    mov rdx, 1      ; number of bytes to write
    syscall         ; invoke the system call

    ; Exit the program
    mov rax, 60     ; syscall number for sys_exit (60)
    xor rdi, rdi    ; return code 0
    syscall         ; invoke the system call
