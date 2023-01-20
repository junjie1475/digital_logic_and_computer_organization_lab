#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>
#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

unsigned long main_time = 0;
Vtop* top;
VerilatedVcdC* tfp;
void nvboard_bind_all_pins(Vtop* top);

void step()
{
	top->clk = 1; top->eval();
	tfp->dump(main_time);
	main_time++;
	top->clk = 0; top->eval();
	tfp->dump(main_time);
	main_time++;
}

int main(int argc, char** argv)
{
   VerilatedContext* contextp = new VerilatedContext; 
   contextp->commandArgs(argc, argv);
   top = new Vtop{contextp};
  
	Verilated::traceEverOn(true);
	tfp = new VerilatedVcdC;
	top->trace(tfp, 99);
	tfp->open("./simx.vcd");

	top->reset = 1;
	step();
	top->reset = 0;
	step();
	step();
	step();
	top->vram[0] = 97;
	int i = 0;
   while(i < 240000)
   {		
		step();
		i++;
   }

	tfp->close();
}
