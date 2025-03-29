.global _start

.section .data
	hello: .asciz "Hello World\n"
	
.section .text

_start:
	
	mov r0 ,#1
	ldr r1, =hello
	ldr r2, =13
	mov r7, #4
	swi 0
	
	mov r0,#0
	mov r7 ,#1
	swi 0
	
