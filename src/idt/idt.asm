section .asm

global idt_load
idt_load:
  push ebp
  mov ebp, esp

  mov ebx, [ebp+8]
  ; ebp points to the base pointer
  ; ebp+4 points to the return address
  ; ebp+8 points to the first function argument
  lidt [ebx] ; this loads idt

  pop ebp
  ret
