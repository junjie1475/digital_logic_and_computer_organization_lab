module encoder83(
   input [7:0] in,
   output reg [2:0] out,
   output reg indicator
); 
  
   always @(*) begin
      out = 3'b0;
      indicator = 1;
      casez(in[7:0])
         8'b1???????: out = 3'b111; 
         8'b01??????: out = 3'b110; 
         8'b001?????: out = 3'b101; 
         8'b0001????: out = 3'b100; 
         8'b00001???: out = 3'b011; 
         8'b000001??: out = 3'b010; 
         8'b0000001?: out = 3'b001; 
         8'b00000001: out = 3'b000; 
      
         default: indicator = 0;
      endcase
   end 
endmodule

module bcd7seg(
   input  [3:0] b,
   output reg [6:0] h
);
   
   always @(*) begin
      case(b)
         4'd0: h = 7'b1111110;
         4'd1: h = 7'b0110000;
         4'd2: h = 7'b1101101;
         4'd3: h = 7'b1111001;
         4'd4: h = 7'b0110011;
         4'd5: h = 7'b1011011;
         4'd6: h = 7'b1011111;
         4'd7: h = 7'b1110000;
         4'd8: h = 7'b1111111;
         4'd9: h = 7'b1111011;
         4'ha: h = 7'b1110111;
         4'hb: h = 7'b0011111;
         4'hc: h = 7'b0001110;
         4'hd: h = 7'b0111101;
         4'he: h = 7'b1001111;
         4'hf: h = 7'b1000111;
         default: h = 7'b0;
      endcase
      h = ~h;
   end 
endmodule

module top(
   input [7:0] in,
   output [2:0] led,
   output led_in,
   output [6:0] seg0
);
   encoder83 ins1(in, led, led_in);
   bcd7seg ins2({1'b0, led}, seg0);
endmodule 
