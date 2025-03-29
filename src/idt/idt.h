#ifndef IDT_H
#define IDT_H

#include "stdint.h"

struct idt_desc
{
  uint16_t offset_1; /* Offset 0-15 bits */
  uint16_t selector; // Selector in GDT
  uint8_t zero; // unused set to zero
  uint8_t type_attr; // Descriptor type and attributes
  uint16_t offset_2; // Offset bits 16-31
}__attribute__((packed));

struct idtr_desc{
  uint16_t limit ; // size of Descriptor table -1
  uint32_t base ; // base address of start of table
}__attribute__((packed));

void idt_init();

#endif // !IDT_H
