#include "idt.h"
#include "../config.h"
#include "../memory/memory.h"
#include "stdint.h"
#include "kernel.h"


struct idt_desc idt_descriptors[TOTAL_INTERRUPTS];
struct idtr_desc idtr_descriptor;

extern void idt_load(struct idtr_desc* ptr);

void idt_zero(){
  print("Error : Divide by zero\n");
}

void idt_set(int interrupt_no,void* address){
  struct idt_desc* desc = &idt_descriptors[interrupt_no];
  desc-> offset_1 = (uint32_t) address & 0x0000ffff;
  desc-> offset_2 = KERNEL_CODE_SELECTOR;
  desc-> zero = 0x00;
  desc-> type_attr = 0xEE; // The first E is such that the extra values of descriptor privelage level, storage segment  and gate type are also set up automatically.
  desc-> offset_2 = (uint32_t) address >>16;                           
}

void idt_init()
{
  memset(idt_descriptors,0,sizeof(idt_descriptors));
  idtr_descriptor.limit = sizeof(idt_descriptors) - 1;
  idtr_descriptor.base = (uint32_t) idt_descriptors;

  idt_set(0,idt_zero);

  // load the idt
  idt_load(&idtr_descriptor);
}
