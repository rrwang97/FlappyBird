//This module holds the states for the line animation.
module lineMachine(input logic clk, reset, move, 
						 output logic [10:0] x0, y0, x1, y1, 
						 output logic color, start
						 );
	enum { A, B, C, D, E, F } ps, ns;
	
	//Line information for each state
	always_comb begin
		case(ps)
			A: begin
					ns = B;
					x0 = 320;
					y0 = 240;
					x1 = 80;
					y1 = 240;
					color = 1;
				end
			B: begin
					ns = C;
					x0 = 320;
					y0 = 240;
					x1 = 80;
					y1 = 240;
					color = 0;
				end
			C: begin
					ns = D;
					x0 = 320;
					y0 = 240;
					x1 = 160;
					y1 = 120;
					color = 1;
				end
			D: begin
					ns = E;
					x0 = 320;
					y0 = 240;
					x1 = 160;
					y1 = 120;
					color = 0;
				end
			E: begin
					ns = F;
					x0 = 320;
					y0 = 240;
					x1 = 240;
					y1 = 0;
					color = 1;
				end
			F: begin
					ns = A;
					x0 = 320;
					y0 = 240;
					x1 = 240;
					y1 = 0;
					color = 0;
				end
		endcase
	end
		
	//Logic for which state to move to
	always_ff @(posedge clk) begin
		if (reset) ps <= A;
		else if (move) begin ps <= ns; start <= 1; end
		else start <= 0;
	end
						 
endmodule 

//Testbench for the lineMachine
module lineMachine_testbench();
	
	//Initializes all logic for module
	logic clk, reset, move, color, start;
	logic [10:0] x0, y0, x1, y1;
	
	//Creates a clock period and clock
	parameter CLOCK_PERIOD=10;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	lineMachine dut (clk, reset, move, x0, y0, x1, y1, color, start);
	
	initial begin
		reset=0; #10;
		reset=1; #10;
		reset=0; move=1; #100;
		$stop;
	end

endmodule 