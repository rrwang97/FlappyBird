
module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, KEY, SW, GPIO_0);
	input logic CLOCK_50; // 50MHz clock.
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY; // True when not pressed, False when pressed
	input logic [9:0] SW;
	output logic [35:0] GPIO_0;

	// Generate clk off of CLOCK_50, whichClock picks rate.
	logic [31:0] clk;
	parameter whichClock = 24;
	clock_divider cdiv (CLOCK_50, clk);
	
	// Default values, turns off the HEX displays
	 assign HEX0 = 7'b1111111;
	 assign HEX1 = 7'b1111111;
	 assign HEX2 = 7'b1111111;
	 assign HEX3 = 7'b1111111;
	 assign HEX4 = 7'b1111111;
	 assign HEX5 = 7'b1111111;
	 
endmodule

// testbench for overall system
module DE1_SoC_testbench();
	 logic clk;
	 logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	 logic [9:0] LEDR;
	 logic [3:0] KEY;
	 logic [9:0] SW;
	 logic [35:0] GPIO_0;

	 DE1_SoC dut (.CLOCK_50(clk), .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR,
	.SW, .GPIO_0);

	 parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
														@(posedge clk);
								SW[0] <= 1;			@(posedge clk);
								SW[0] <= 0;	
								KEY[3] <= 0;  								//entering test, should incr
								KEY[2] <= 1;			@(posedge clk);
										repeat(3)	@(posedge clk);
										
								KEY[3] <= 0;  		
								KEY[2] <= 0;			@(posedge clk);
										repeat(3)	@(posedge clk);
										
								KEY[3] <= 1;  		
								KEY[2] <= 0;			@(posedge clk);
										repeat(3)	@(posedge clk);
										
								KEY[3] <= 1;  		
								KEY[2] <= 1;			@(posedge clk);
										repeat(3)	@(posedge clk);
										
								KEY[3] <= 1;  								//exiting test, should decr
								KEY[2] <= 0;			@(posedge clk);
										repeat(3)	@(posedge clk);
										
								KEY[3] <= 0;  		
								KEY[2] <= 0;			@(posedge clk);
										repeat(3)	@(posedge clk);
										
								KEY[3] <= 0;  		
								KEY[2] <= 1;			@(posedge clk);
										repeat(3)	@(posedge clk);
										
								KEY[3] <= 1;  		
								KEY[2] <= 1;			@(posedge clk);
										repeat(3)	@(posedge clk);	
																				// no more tests bc car CANNOT CHANGE DIR
										
	
		$stop;
	end
endmodule 
