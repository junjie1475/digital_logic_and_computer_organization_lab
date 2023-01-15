#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

unsigned long main_time = 0;
Vtop* top;
VerilatedVcdC* tfp;

void nvboard_bind_all_pins(Vtop* top);

unsigned char check_parity(unsigned char x)
{
	x ^= x >> 4;
	x ^= x >> 2;
	x ^= x >> 1;
	return ~x & 1;
}

void step()
{
	top->clk = 1; top->eval();
	tfp->dump(main_time);
	main_time++;
	top->clk = 0; top->eval();
	tfp->dump(main_time);
	main_time++;
}
void test1(unsigned char code)
{
	top->ps2_clk = 0;
	int count = 0, count2 = 0, end = 0;

	while(1)
	{
		if(count % 3 == 0)
		{
			if(end) break;
			if(count % 6 == 0)
			{
				if(count2 == 0) top->ps2_data = 0;
				else if(count2 >= 1 && count2 <= 8) top->ps2_data = (code & (1 << (count2 - 1))) >> count2 - 1;
				else if(count2 == 9) top->ps2_data = ~__builtin_parity(code) & 1;
				else 
				{
					top->ps2_data = 1;
					end = 1;
				}
				count2++;
			}
			top->ps2_clk = top->ps2_clk == 1 ? 0 : 1;
		}

		count++;
		step();
	}

	top->ps2_clk = top->ps2_clk == 1 ? 0 : 1;
	step();
	top->ps2_clk = top->ps2_clk == 1 ? 0 : 1;
	step();
	step();
}

void _round(unsigned char code)
{
 	test1(code);

//	printf("data: %x\n", top->data_out);
//	printf("ready: %x\n", top->ready);
//	printf("overflow: %x\n", top->overflow);
	printf("-----------------------------------\n");
//	top->nextdata_n = 0;
	step();
//	top->nextdata_n = 1;
	step();
}

void round2(unsigned char code)
{
 	test1(code);

	step();
//	printf("data: %x\n", top->data_out);
//	printf("ready: %x\n", top->ready);
//	printf("overflow: %x\n", top->overflow);
	printf("-----------------------------------\n");
	step();
	step();
}

int main(int argc, char** argv)
{

   VerilatedContext* contextp = new VerilatedContext; 
   contextp->commandArgs(argc, argv);
   top = new Vtop{contextp};
	

	Verilated::traceEverOn(true);
	tfp = new VerilatedVcdC;
	top->trace (tfp, 99);
	tfp->open ("./simx.vcd");

	// init
//	top->nextdata_n = 1;
	top->clrn = 0;
	step();
	top->clrn = 1;
	step();

	round2(0x1C);
	round2(0xF0);
	round2(0x1C);
	round2(0x1B);
	round2(0x1B);
	round2(0x1B);
	round2(0xF0);
	round2(0x1B);
	tfp->close();
}
