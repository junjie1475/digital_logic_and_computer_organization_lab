#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>
#include "Vtop.h"
#include "verilated.h"
#include <nvboard.h>

Vtop* top;
void nvboard_bind_all_pins(Vtop* top);
void step()
{
	top->clk = 1; top->eval();
	top->clk = 0; top->eval();
}
int main(int argc, char** argv)
{
   VerilatedContext* contextp = new VerilatedContext; 
   contextp->commandArgs(argc, argv);
   top = new Vtop{contextp};
  
   nvboard_bind_all_pins(top);
   nvboard_init();
	
	top->reset = 1;
	step();
	top->reset = 0;
	step();
	step();
	step();

   while(1)
   {		
      nvboard_update();
		step();
   }
  
}
