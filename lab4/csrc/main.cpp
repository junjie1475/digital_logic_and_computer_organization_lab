#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "Vlfsr.h"
#include "verilated.h"
#include <nvboard.h>
Vlfsr* top;
void nvboard_bind_all_pins(Vlfsr* top);
int main(int argc, char** argv)
{
   VerilatedContext* contextp = new VerilatedContext; 
   contextp->commandArgs(argc, argv);
   top = new Vlfsr{contextp};
  
   nvboard_bind_all_pins(top);
   nvboard_init();

   while(1)
   {
      nvboard_update();
      top->eval();
   }
  
}
