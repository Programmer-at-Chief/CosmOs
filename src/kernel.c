#include "kernel.h"
#include "stdint.h"
#include "stddef.h"
#include "idt/idt.h"

uint16_t* video_mem = 0 ;
void terminal_putchar(int,int,char,char);
size_t strlen(const char*);
void terminal_initialize();
uint16_t terminal_make_char(char ,char);
void terminal_write_char(char,char);
void print(const char*);
void clear_terminal();

uint16_t terminal_row = 0;
uint16_t terminal_col = 0;

void print(const char* string){
  int i = 0;
  while (i<strlen(string)){
    terminal_write_char(string[i], 15);
    i++;
  }
}

void terminal_write_char(char c,char color){
  if (c == '\n'){
    terminal_col = 0;
    terminal_row++;
    return;
  }
  else if (c=='\t'){
    terminal_col+=3;
    return;
  }
  terminal_putchar(terminal_col, terminal_row, c, color);
  terminal_col++;
  if (terminal_col >= VGA_WIDTH){
    terminal_row++;
    terminal_col= 0;
  }
  if (terminal_row>=VGA_HEIGHT){
    clear_terminal();
    terminal_row= 0;
    terminal_col = 0;

  }
}

uint16_t terminal_make_char(char c,char colour){
  return (colour<< 8 ) | c;
}

void terminal_initialize(){
  video_mem = (uint16_t*)(0xB8000);
  /*Clear the terminal */
  clear_terminal();
  }

void clear_terminal(){
  for(int y=0;y<VGA_HEIGHT;y++){
    for (int x = 0;x<VGA_WIDTH;x++){
      terminal_putchar(x,y,' ',0);
    }
  }
  terminal_row = 0;
  terminal_col = 0;

}

size_t strlen(const char* arr){
  int len = 0;
  while(arr[len]) len++;
  return len;
}

void terminal_putchar(int x,int y,char c,char color){
  video_mem[y*VGA_WIDTH+ x] = terminal_make_char(c,color);
}

void kernel_main()
{
  /*video_mem[0] = 0x0341;  little endian : LSB first*/
  terminal_initialize();

  char* display = "Hello World!";
  /**/
  /*int i = 0;*/
  /*int len = strlen(display);*/
  /*while(i<len){*/
  /*  terminal_write_char(display[i], 15);*/
    /*video_mem[i] = terminal_make_char(display[i], 15);*/
  /*  i++;*/
  /*}*/
  print(display);

  terminal_write_char('\n', 15);

  terminal_write_char('H', 15);
  terminal_write_char('i', 15);
  terminal_write_char(' ', 15);

  terminal_write_char('\t', 15);
  terminal_write_char('H', 15);
  terminal_write_char('E', 15);
  terminal_write_char('L', 15);
  terminal_write_char('L', 15);

  // Initialize the interrupt descriptor table
  idt_init();

}
