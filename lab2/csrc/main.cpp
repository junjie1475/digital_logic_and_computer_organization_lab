#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "Vtop.h"
#include "verilated.h"
#include <nvboard.h>
Vtop* top;
void nvboard_bind_all_pins(Vtop* top);
int main(int argc, char** argv)
{
   VerilatedContext* contextp = new VerilatedContext; 
   contextp->commandArgs(argc, argv);
   top = new Vtop{contextp};
  
   nvboard_bind_all_pins(top);
   nvboard_init();

   while(1)
   {
      nvboard_update();
      top->eval();
   }
  
}
