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
	
	for(int j = 0; j < 30; j++)
	{
		for(int i = 0; i < 70; i++)
		{
			top->vram[j * 128 + i] = 65 + i;
		}
	}

   while(1)
   {		
      nvboard_update();
		step();
		top->eval();
		top->eval();
   }
  
}
