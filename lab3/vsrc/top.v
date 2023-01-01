module adder(
	input  [3:0]  A, B,
	input cin,
	output [3:0]  Result,
	output overflow,
	output carry,
	output zero
);
	wire [3:0] t_add_Cin;
	wire carry_;
	assign t_add_Cin =( {4{cin}}^B )+ {3'b0, cin};  
	assign { carry_, Result } = A + t_add_Cin;
	assign overflow = (A[3] == t_add_Cin[3]) && (Result [3] != A[3]);
	assign zero = ~(| Result);
	assign carry = carry_ ^ cin;
endmodule

module alu(
   input [3:0] A,
   input [3:0] B,
   input [2:0] sel,
   output reg [3:0] Result,
   output reg overflow,
   output reg carry,
   output reg zero
);
   wire [3:0] Result_, Result__;
   wire overflow_, overflow__;
   wire carry_, carry__;	
   wire zero_, zero__;  	
	
	adder in1(A, B, 0, Result_, overflow_, carry_, zero_); 
	adder in2(A, B, 1, Result__, overflow__, carry__, zero__); 
   // Add
   always @(*) begin
		Result = 4'b0; overflow = 0; carry = 0; zero = 0;
      case(sel)
			3'b000: begin Result = Result_; overflow = overflow_; carry = carry_; zero = zero_; end 
			3'b001: begin Result = Result__; overflow = overflow__; carry = carry__; zero = zero__; end
			3'b010: Result = ~A;
			3'b011: Result = A & B;
			3'b100: Result = A | B;
			3'b101: Result = A ^ B;
			3'b110: Result = {3'b0, (Result__[3] ^ overflow__) & (|(B ^ 4'b1000))}; 
			3'b111: Result = {3'b0, zero__};
      endcase
   end

endmodule  
