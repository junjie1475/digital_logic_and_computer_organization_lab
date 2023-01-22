`include "mux.v"
`include "keyboard.v"
module vga_ctrl(
    input           pclk,     //25MHz时钟
    input           reset,    //置位
    input  [23:0]   vga_data, //上层模块提供的VGA颜色数据
    output [9:0]    h_addr,   //提供给上层模块的当前扫描像素点坐标
    output [9:0]    v_addr,
    output          hsync,    //行同步和列同步信号
    output          vsync,
    output          valid,    //消隐信号
    output [7:0]    vga_r,    //红绿蓝颜色信号
    output [7:0]    vga_g,
    output [7:0]    vga_b
    );

  //640x480分辨率下的VGA参数设置
  parameter    h_frontporch = 96;
  parameter    h_active = 144;
  parameter    h_backporch = 784;
  parameter    h_total = 800;

  parameter    v_frontporch = 2;
  parameter    v_active = 35;
  parameter    v_backporch = 515;
  parameter    v_total = 525;

  //像素计数值
  reg [9:0]    x_cnt;
  reg [9:0]    y_cnt;
  wire         h_valid;
  wire         v_valid;

  always @(posedge reset or posedge pclk) //行像素计数
      if (reset == 1'b1)
        x_cnt <= 1;
      else
      begin
        if (x_cnt == h_total)
            x_cnt <= 1;
        else
            x_cnt <= x_cnt + 10'd1;
      end

  always @(posedge pclk)  //列像素计数
      if (reset == 1'b1)
        y_cnt <= 1;
      else
      begin
        if (y_cnt == v_total & x_cnt == h_total)
            y_cnt <= 1;
        else if (x_cnt == h_total)
            y_cnt <= y_cnt + 10'd1;
      end
  //生成同步信号
  assign hsync = (x_cnt > h_frontporch);
  assign vsync = (y_cnt > v_frontporch);
  //生成消隐信号
  assign h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
  assign v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);
  assign valid = h_valid & v_valid;
  //计算当前有效像素坐标
  assign h_addr = h_valid ? (x_cnt - 10'd145) : {10{1'b0}};
  assign v_addr = v_valid ? (y_cnt - 10'd36) : {10{1'b0}};
  //设置输出的颜色值
  assign vga_r = vga_data[23:16];
  assign vga_g = vga_data[15:8];
  assign vga_b = vga_data[7:0];
endmodule


module top(
	input clk,
	input reset,
	input ps2_clk,
	input ps2_data,
	output vga_blank,
	output vga_hsync,
	output vga_vsync,
	output [7:0]    vga_r,
	output [7:0]    vga_g,
	output [7:0]    vga_b,
	output reg [7:0] seg1,
	output reg [7:0] seg2
);
	wire [23:0] vga_data;
	wire [9:0] haddr;
	wire [9:0] vaddr;
	
	reg [7:0] vram_output;
	
	reg [3:0] counter_x;
	reg [3:0] counter_y;
	reg [6:0] vram_x;
	reg [4:0] vram_y;
	reg [8:0] rom [4095:0];
	reg [7:0] vram [3839:0];
	wire en;
	wire [7:0] ascii;
	initial
	begin
	$readmemh("/home/sqq338/digital_logic_and_computer_organization_lab/lab7/resource/rom", rom);
	$display("%d", vram[0]);
	end
	wire out;	
	mux91b mux(rom[{vram_output, counter_y}], counter_x, out); 

	keyboard k(clk, reset, ps2_clk, ps2_data, en, ascii, seg1, seg2); 

	reg init;
	always @(negedge clk) begin
		if(init == 0) begin
			init <= 1;
			vram[0] <= 62;
			index_x <= 1;
		end
	end
	reg [6:0] index_x;
	reg [4:0] index_y;
	reg [19:0] limit;
	reg [6:0] x;
	reg [4:0] y;

	always @(negedge clk) begin
		x <= index_x == 0 ? vram[{index_y - 1'd1, 7'd73}] : index_x - 1;
		y <= index_x == 0 ? index_y - 1 : index_y;
	end
	reg [19:0] counter_;
	always @(posedge clk) begin
		if(counter_ == 0)
			vram[{index_y, index_x}] <= vram[{index_y, index_x}] ^ 219;
		counter_ <= counter_ + 1;
		if(en) 
			limit <=	limit + 1;
		if(en & limit == 0) begin
			if(ascii == 13) begin
				index_y <= index_y + 1; // inc the y pointer to next line
				index_x <= 1;
				vram[{index_y, 7'd73}] <= index_x; 
				vram[{index_y, index_x}] <= 0;
				vram[{index_y + 1'd1, 7'd0}] <= 62;
			end
			else if(ascii == 8'h8)
			begin
				index_x <= x;
				index_y <= y;
				vram[{y, x}] <= 0;
				vram[{index_y, index_x}] <= 0;
			end
			else begin
				vram[{index_y, index_x}] <= ascii;
				index_x <= index_x + 1;
				if(index_x == 69)
				begin 
					index_x <= 0;
					index_y <= index_y + 1;
					vram[{index_y, 7'd73}] <= index_x + 1;
				end
			end
		end
		else if(en == 0)
			limit <= 0;
	end
//=====================================================
	assign vga_data = {24{out}};
	always @(posedge clk) begin
		if(vga_vsync == 0)
		begin
			vram_x <= 0;
			vram_y <= 0;
			counter_x <= 0;
			counter_y <= 0;
		end
		
		if(vga_hsync == 0)
		begin
			counter_x <= 0;
			vram_x <= 0;
		end
	end

	always @(negedge clk) begin
		if(haddr >= 630) vram_output <= 0;
		else vram_output <= vram[{vram_y, vram_x}];
	end

	reg [3:0] counter_y_d;
	always @(posedge clk) begin 
		counter_y_d <= counter_y;
		if(counter_x == 8) 
			vram_x <= vram_x + 1;		

		if(counter_y_d == 15 & counter_y == 0)
			vram_y <= vram_y + 1;
	end
	
	reg [1:0] sample;
	
	always @(posedge clk) begin
		sample <= {sample[0], vga_blank};
		if(sample[1] & ~sample[0])
		begin
	  		if(counter_y == 15) counter_y <= 0;
			else	counter_y <= counter_y + 1;
			counter_x <= 0; // width: 640, 640%9=1, reset counter to 0 for next line
		end

		if(vga_blank)
		begin
			if(counter_x == 8) counter_x <= 0;
			else counter_x <= counter_x + 1;
		end
	end

	vga_ctrl clt(clk, reset, vga_data, haddr, vaddr, vga_hsync, vga_vsync, vga_blank, vga_r, vga_g, vga_b);
	
endmodule
