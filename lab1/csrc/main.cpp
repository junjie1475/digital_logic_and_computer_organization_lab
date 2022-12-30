#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "Vmux41.h"
#include "verilated.h"
#include <nvboard.h>
Vmux41* top;
void nvboard_bind_all_pins(Vmux41* top);
int main(int argc, char** argv)
{
  VerilatedContext* contextp = new VerilatedContext; 
  contextp->commandArgs(argc, argv);
  top = new Vmux41{contextp};
  
//  top->a = 0b11100100;
//  top->s = 0b00;
//  top->eval();
//  assert(top->f == 0b00);
//  top->s = 0b01;
//  top->eval();
//  assert(top->f == 0b01);
//  top->s = 0b10;
//  top->eval();
//  assert(top->f == 0b10);
//  top->s = 0b11;
//  top->eval();
//  assert(top->f == 0b11);

   nvboard_bind_all_pins(top);
   nvboard_init();

   while(1)
   {
     nvboard_update();
     top->eval();
   }
  
}
