module userInput (clk, reset, in, out);
	input logic clk, reset, in;
	output logic out;	
	logic firstOut, secondOut;
	
	Dflip firstDFF (.clk, .reset, .in, .out(firstOut));
	Dflip secondDFF (.clk, .reset, .in(firstOut), .out(secondOut));
	
	enum {A = 0, B = 1} ps, ns;
	
	always_comb begin
		case (ps)
			A: if (secondOut) ns = B;
				else ns = A;
			B: if (~secondOut) ns = A;
				else ns = B;
		endcase
	end
	
	assign out = ((ns == B) & (ps == A));
	
	always_ff @(posedge clk) begin
		if (reset)
			ps <= A;
		else
			ps <= ns;
	end	
endmodule 

module Dflip (clk, reset, in, out);
	input logic clk, reset, in;
	output logic out;
	

	always_ff @(posedge clk) begin
		if (reset)
			out <= 0;
		else
			out <= in;
		end
endmodule 

module userInput_testbench();
	logic clk, reset, in, out;
	
	userInput dut (clk, reset, in, out);	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
											@(posedge clk);									
			reset <= 1;					@(posedge clk);
			reset <= 0;	in <= 1;		@(posedge clk);									
											@(posedge clk);																
											@(posedge clk);									
							in <= 0;		@(posedge clk);									
											@(posedge clk);									
											@(posedge clk);									
							in <= 1;		@(posedge clk);									
											@(posedge clk);									
											@(posedge clk);	
											@(posedge clk);									

		$stop;
	end								
endmodule 