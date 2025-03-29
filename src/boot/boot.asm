org 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start :
  jmp short start
  nop

times 33 db 0

start:
  jmp 0:step2

step2:
  cli
  mov ax, 0x00
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x7c00
  sti

.load_protected:
  cli 
  lgdt[gdt_descriptor] ; lgdt -> load global descriptor table

  ; Set the first bit of cr0 to 1, loads protected mode
  mov eax,cr0
  or eax,0x1
  mov cr0,eax

  jmp CODE_SEG:load32
  jmp $

; GDT
gdt_start:
gdt_null:
  dd 0x0
  dd 0x0
  ; 64 bit of zeroes

;offset 0x8
gdt_code: ; Code segments should point to this
  dw 0xffff ; Segment limit first 0-15 bits
  dw 0 ; Base 0-15 bits
  db 0 ; Base 16-23 bits
  db 0x9a ; Access byte
  db 11001111b ; High 4 bit and low 4 bit flags
  db 0

; offset 0x10
gdt_data: ; DS SS ES FS GS
  dw 0xffff ; Segment limit first 0-15 bits
  dw 0 ; Base 0-15 bits
  db 0 ; Base 16-23 bits
  db 0x92 
  db 11001111b ; High 4 bit and low 4 bit flags
  db 0

gdt_end:

gdt_descriptor:
  dw gdt_end - gdt_start - 1 ; size of gdt_descriptor
  dd gdt_start

[BITS 32] ; kernel driver to load kernel in memory
load32:
  mov eax, 1 ; go to boot sector
  mov ecx, 100 ; 100 sectors
  mov edi, 0x0100000 ; hex values 1 M 
  call ata_lba_read
  jmp CODE_SEG:0x0100000 ; CODE_SEG * 16 + 0x0100000 

ata_lba_read:
  mov ebx, eax, ; backup the LBA
  ; Send the highest 8 bits of the lba to the hark disk controller 
  shr eax, 24 ; 32-24 = 8, this is a right shift by 24 bits 
  or eax, 0xE0 ; select the master drive
  mov dx, 0x1F6 ; hard disk port
  out dx, al ; al contains highest 8 bits of the lba

  ; Send the total sectors to read
  mov eax,ecx
  mov dx, 0x1F2
  out dx, al
  ; Finished sending the total sectors to read

  ; Send more bits of the lba
  mov eax, ebx ; restore the backup lba
  mov dx, 0x1F3
  out dx, al
  ; Finished sending more bits of the lba

  mov dx, 0x1F4
  mov eax, ebx
  shr eax, 8
  out dx, al
  ; Finished sending more bits of the lba

  ; Send upper 16 bits of the lba
  mov dx, 0x1F5
  mov eax, ebx
  shr eax, 16
  out dx, al

  ; Finished sending upper 16 bits of the lba

  mov dx, 0x1F7
  mov al, 0x20
  out dx, al

  ; Read all sectors in memory

.next_sector:
  push ecx

; Check if we need to read
.try_again:
  mov dx, 0x1F7
  in al, dx
  test al, 8
  jz .try_again

; Read 256 words at a time
  mov ecx, 256 ; 512 bytes
  mov dx, 0x1F0
  rep insw ; This reads a word from 0x1F0 and storing it in edi
  pop ecx
  loop .next_sector
  ; The last two operations are the loop to read the 100 sectors 

  ; end of reading sectors
  ret

times 510 - ($ - $$) db 0
dw 0xAA55
