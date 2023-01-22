`include "PS2ScanToAscii.v"
module ps2_keyboard(clk,clrn,ps2_clk,ps2_data,data,
                    ready,nextdata_n);
   input clk,clrn,ps2_clk,ps2_data;
   input nextdata_n;
   output [7:0] data;
   output reg ready;
   reg overflow;     // fifo overflow
   // internal signal, for test
   reg [9:0] buffer;        // ps2_data bits
   reg [7:0] fifo[7:0];     // data fifo
   reg [2:0] w_ptr,r_ptr;   // fifo write and read pointers
   reg [3:0] count;  // count ps2_data bits
   // detect falling edge of ps2_clk
   reg [2:0] ps2_clk_sync;

   always @(posedge clk) begin
       ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};
   end

   wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

   always @(posedge clk) begin
       if (clrn == 1) begin // reset
           count <= 0; w_ptr <= 0; r_ptr <= 0; overflow <= 0; ready<= 0;
       end
       else begin
           if ( ready ) begin // read to output next data
               if(nextdata_n == 1'b0) //read next data
               begin
                   r_ptr <= r_ptr + 3'b1;
                   if(w_ptr==(r_ptr+1'b1)) //empty
                       ready <= 1'b0;
               end
           end
           if (sampling) begin
             if (count == 4'd10) begin
               if ((buffer[0] == 0) &&  // start bit
                   (ps2_data)       &&  // stop bit
                   (^buffer[9:1])) begin      // odd  parity
                   fifo[w_ptr] <= buffer[8:1];  // kbd scan code
                   w_ptr <= w_ptr+3'b1;
                   ready <= 1'b1;
                   overflow <= overflow | (r_ptr == (w_ptr + 3'b1));
               end
               count <= 0;     // for next
             end else begin
               buffer[count] <= ps2_data;  // store ps2_data
               count <= count + 3'b1;
             end
           end
       end
   end
   assign data = fifo[r_ptr]; //always set output data

endmodule


module register2(clk,clr,d,q,load);
   input  load,clr,clk;
   input  [2:0] d;
   output reg [2:0] q;

  always @(posedge clk)
     if (clr==1)
        q <= 0;
     else if (load == 1)
        q <= d;
endmodule

// if en is 1, the key is pressing. 
module keyboard(
    input clk,clrn,ps2_clk,ps2_data,
	 output wire en,
	 output reg [7:0] ascii,
	 output reg [7:0] seg1,
	 output reg [7:0] seg2
);
	wire [7:0] data;
   reg nextdata_n;
   reg [7:0] data_out;
	wire ready;

	ps2_keyboard in1(clk, clrn, ps2_clk, ps2_data, data, ready, nextdata_n);

	always @(posedge clk) if(ready) data_out <= data;
	always @(negedge clk) if(ready) nextdata_n <= 0;
	always @(posedge clk) if(nextdata_n == 0) nextdata_n <= 1;
	always @(posedge clk) if(clrn == 1) nextdata_n <= 1;	

	parameter[2:0] S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;
	wire [2:0] state_din, state_dout;
	wire state_wen;
	reg [1:0] sample;
	reg [7:0] count;
	
	always @(posedge clk) sample <= {sample[0], nextdata_n};

	register2 state(clk, clrn, state_din, state_dout, state_wen);
	
	assign state_wen = 1;

	MuxKeyWithDefault#(5, 3, 1) outMux(.out(en), .key(state_dout), .default_out(0), .lut({
	  S0, 1'b0,
	  S1, 1'b0,
	  S2, 1'b0,
	  S3, 1'b0,
	  S4, 1'b1
	}));

	MuxKeyWithDefault#(5, 3, 3) stateMux(.out(state_din), .key(state_dout), .default_out(0), .lut({
	  S0, (sample[1] & ~sample[0]) ? (data_out == 8'h5A ? S1 : S4) : S0, // detect falling edge
	  S1, data_out == 8'hF0 ? S2 : S1,
	  S2, data_out == 8'hF0 ? S2 : S3,
	  S3, (sample[1] & ~sample[0]) ? S4 :  S3,
	  S4, data_out == 8'hF0 ? S2 : S4
	}));
	reg [7:0] delay;
	always @(posedge clk) delay <= data_out;
	
	PS2ScanToAscii lut(0, 0, 0, 0, delay, ascii);
	bcd7seg in3(ascii[3:0], en, seg1);
	bcd7seg in4(ascii[7:4], en, seg2);

endmodule

module bcd7seg(
   input  [3:0] b,
	input enable,
   output reg [7:0] h
);
   
   always @(*) begin
		if(!enable) begin
			h = 8'b0;
		end else begin
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
			endcase	
      end
      h = ~h;
   end 
endmodule
