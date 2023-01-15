module bcd7seg(
   input  [3:0] b,
   output reg [7:0] h
 );

  always @(*) begin
       case(b)
          4'd0: h = 8'b11111100;
			 4'd1: h = 8'b01100000;
          4'd2: h = 8'b11011010;
          4'd3: h = 8'b11110010;
          4'd4: h = 8'b01100110;
          4'd5: h = 8'b10110110;
          4'd6: h = 8'b10111110;
          4'd7: h = 8'b11100000;
          4'd8: h = 8'b11111110;
          4'd9: h = 8'b11110110;
          4'ha: h = 8'b11101110;
          4'hb: h = 8'b00111110;
          4'hc: h = 8'b10011100;
          4'hd: h = 8'b01111010;
          4'he: h = 8'b10011110;
          4'hf: h = 8'b10001110;
          default: h = 8'b0;
       endcase
       h = ~h;
    end
endmodule
module lfsr(
	input clk,
	output [7:0] seg0, seg1
);
	reg [7:0] shift = 0'b00000001;
	always @(posedge clk) begin
		shift <= {shift[4] ^ shift[3] ^ shift[2] ^ shift[0], shift[7:1]};
	end
	bcd7seg ins1(shift[3:0], seg0);
	bcd7seg ins2(shift[7:4], seg1);
endmodule
