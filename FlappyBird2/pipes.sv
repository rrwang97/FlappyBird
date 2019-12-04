// Module to track pipes coordinates
// Inputs: reset, clk(CLOCK_50MHz), pipe_length -- a random number from LFSR
// Outputs: x0, y0, x1, y1 coords for the pipe 
module pipes #(parameter PIPE_WIDTH = 20, BIRD_SIZE = 15, START_X = 640) 
			(reset, clk, start, pipe_length, x0, x1, y0, y1);
	input logic reset, clk, start;
	input logic [9:0] pipe_length;
	
	output logic [9:0] x0, x1;	
	output logic [8:0] y0, y1;
	
	logic [8:0] ytop, ybot;
	
	assign ytop = 0;
	assign ybot = 480;
											
	//	ytop	
	//	    |    |	
	//	 y1 |____|
											
	//	 y0  ____	
	//	    |	   |	
	// ybot|    |
	//	  	x0	  x1
	
	logic move_pipe, CLK_48HZ;
	logic [9:0] hold_pipe_length; // locks value for pipe_length which is always changing
	
	logic [31 : 0] divided_clk; // used to slow down falling bc user can't input fast enough to ever beat a 50MHz clk
									 // Realistically a person can press space 8-9 times per sec
									 // 50MHz / 6.25M = 8 Hz 
									 // divided_clk[0] = 25MHz, [1] = 12.5Mhz, ... [21] = 12Hz, [22] = 6Hz
	
	// Counter for divided clocks
	always_ff @(posedge clk) begin
		if (reset) 
			divided_clk <= '0;
		else
			divided_clk <= divided_clk + 1;
	end
	
	userInput dividedclk (.reset, .clk, .in(divided_clk[19]), .out(CLK_48HZ));
				
	always_ff @(posedge clk) begin
		if (reset) begin
			hold_pipe_length <= pipe_length; // load a length
			move_pipe <= 0;
			y0 <= 481; // off screen coords
			y1 <= 481;
			x1 <= 641;
			x0 <= 641;
		end
		else if (start) begin
			// Set a y value for the pipes first
			if (!move_pipe) begin
				
				// Gap in bot half 
				if (hold_pipe_length[9]) begin
					y0 <= 240 + (hold_pipe_length[7:0] - 16); // range: 224 - 480
					
					// Wide gap 
					if (hold_pipe_length[8])
						y1 <= 240 + (hold_pipe_length[7:0] - 16) - 2*{hold_pipe_length[0],2'b11}*BIRD_SIZE; // range: 19 - 435
					// Normal gap
					else
						y1 <= 240 + (hold_pipe_length[7:0] - 16) - 4*BIRD_SIZE; // range: 194-450 
				end
					
				// Gap in top half
				else begin
					y1 <= 240 - (hold_pipe_length[7:0] - 16); // range: 0 - 256
					
					// Wide gap
					if (hold_pipe_length[8])
						y0 <= 240 - (hold_pipe_length[7:0] - 16) + 2*{hold_pipe_length[0],2'b11}*BIRD_SIZE; // range: 45 - 361
					// Normal gap		
					else
						y0 <= 240 - (hold_pipe_length[7:0] - 16) + 4*BIRD_SIZE; // range: 30 - 286
				end
		
				// now start moving the pipe across the screen
				x0 <= 640;
				x1 <= 640 + PIPE_WIDTH;
				move_pipe <= 1; 
			end
			
			// decrement x1 til it hits zero then we know to pick another y, i.e. start a new pipe
			else if (CLK_48HZ) begin
				if (x1 == 0) begin
					hold_pipe_length <= pipe_length;
					move_pipe <= 0; // stop decrementing x
				end	
				else begin
					x0 <= x0 - 1;
					x1 <= x1 - 1;
				end
			end
		end
		else begin 
			hold_pipe_length <= pipe_length; // keep sampling new lengths until start
		end
	end
	
endmodule


module pipes_testbench #(parameter PIPE_WIDTH = 1, BIRD_SIZE = 15) ();
	logic reset, clk, start;
	logic [9:0] pipe_length;

	logic [9:0] x0, x1;	
	logic [8:0] y0, y1;
	
	pipes #(.PIPE_WIDTH(PIPE_WIDTH), .BIRD_SIZE(BIRD_SIZE))
		dut (.*);
	
	parameter CLOCK_PERIOD = 10;
	initial begin
		clk <= 0; 
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		start <= 0;
		reset <= 1; #10;
		reset <= 0; #10;
		
		repeat(5) #10; // no ops
		pipe_length <= 10'b_1_1_1111111_1; // bot half, wide --- y0 > 224 and y0 - y1 = 7*15 = 105
		start <= 1; #10;
		repeat(5) #10;
		
		start <= 0;
		reset <= 1; #10;
		reset <= 0; #10;
		pipe_length <= 10'b_1_0_1111111_1; // bot half, normal --- y0 > 240 and y0 - y1 = 30
		start <= 1; #10;
		repeat(5) #10;
		
		start <= 0;
		reset <= 1; #10;
		reset <= 0; #10;
		pipe_length <= 10'b_0_1_1111111_1; // top half, wide --- y1 < 256 and y0 - y1 = 105
		start <= 1; #10;
		repeat(5) #10;
		
		start <= 0;
		reset <= 1; #10;
		reset <= 0; #10;
		pipe_length <= 10'b_0_0_1111111_1; // top half, normal --- y1 < 256 and y0 - y1 = 30
		start <= 1; #10;
		repeat(700) #10; // zero out x
	
		$stop;
	end

	
endmodule
