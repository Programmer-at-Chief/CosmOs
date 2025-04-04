;ORG 07c00 this is the start of bootloader
ORG 0
BITS 16

_start :
  jmp short start
  nop

;Bios Parameter Block
times 33 db 0 ; these 33 bytes may get filled with random data , generated by the bios

start:
  jmp 0x7c0:step2

; Interrupts
handle_zero:
  mov ah, 0eh
  mov al, 'A'
  mov bx, 0x00
  int 0x10
  iret

handle_one:
  mov ah, 0eh
  mov al, 'V'
  mov bx, 0x100
  int 0x10
  iret

step2:
  cli ; Clear interrupts
  mov ax, 0x7c0
  mov ds, ax
  mov es, ax

  
  mov ax, 0x00
  mov ss, ax
  mov sp, 0x7c00
  ; This makes sure the stack starts at 0x0

  sti ; Enables interrupts

  mov ah, 2 ;Read sector command
  mov al, 1 ; 1 sector to read
  mov ch, 0 ; Cylinder low eight bits
  mov cl, 2 ; Read sector two
  mov dh, 0 ; Head number
  mov bx, buffer
  int 0x13 ; Invoke the read command


  ;mov si,20
  ;DS:SI
  ;0x7c0 & 16 = 0x7c00
  ;0x7c00 + si = 0x7cf4 final address

  ; This is interrupt code.
  ;mov word [ss:0x00], handle_zero
  ;mov word [ss:0x02], 0x7c0
  ;
  ;;int 0; This is interrupt 0 , division by zero error 
  ;; We can call interrupts like this
  ;
  ;;mov ax, 0x00
  ;;div ax ; This will divided ax by ax and handle_zero will be called
  ;
  ;mov word[ss:0x04], handle_one
  ;mov word[ss:0x06], 0x7c0
  ;
  ;int 1

  mov si, message
  call print

  mov si, buffer
  call print

  ;;;;; Colors and video type output
  ; Switch to graphics mode 0x13
  ;mov ah, 0x00      ; Video function
  ;mov al, 0x13      ; Mode 0x13 (320x200, 256 colors)
  ;int 0x10          ; Switch to graphics mode

  ; Now output characters with colors
  ;mov ah, 0x0E      ; Teletype output
  ;;;;;


  mov bl, 0x3 ; Color
  
  jc error ; Jump carry error
  jmp $

error:
  mov si, error_message
  call print
  jmp $

print:
  mov bx, 0
.loop:
  lodsb
  cmp al,0
  je .done
  call print_char
  jmp .loop

.done: ; this is a sub label
  ret

print_char:
  mov ah, 0eh ; this will output to screen
  ;mov al, 'A'
  int 0x10 ; this is a bios interrupt
  ret

message: db 'Hello World!',0

error_message : db 'Failed to load, sector!',0

times 510 - ($ - $$) db 0 ; fill 510 bytes of data with 0
dw 0xAA55 ; this is the bios address, little endian

buffer:
