// Clock at 12.5Mhz
module pipes #(parameter N = 11, PIPE_WIDTH = 1, BIRD_SIZE = 15, START_X = 640) 
			(reset, clk, start, pipe_length, x, y0, y1 );
	input logic reset, clk, start;
	input logic [9:0] pipe_length;
	
	output logic [N-1 : 0] x, y0, y1; // y0 should be "lower" pipe, i.e. y0 > y1
	
	logic decr_x, CLK_3HZ;
	
	logic [31 : 0] divided_clk; // used to slow down falling bc user can't input fast enough to ever beat a 50MHz clk
									 // Realistically a person can press space 8-9 times per sec
									 // 50MHz / 6.25M = 8 Hz 
									 // divided_clk[0] = 25MHz, [1] = 12.5Mhz, ... [21] = 12Hz, [22] = 6Hz
	
	always_ff @(posedge clk) begin
		if (reset) 
			divided_clk <= '0;
		else
			divided_clk <= divided_clk + 1;
	end
	
	userInput dividedclk (.reset, .clk, .in(divided_clk[23]), .out(CLK_3HZ));
	
	parameter// START_X = 640 - PIPE_WIDTH, // starts on far right of screen
				START_Y0 = 240 + BIRD_SIZE,  // gap of 2x the size of the bird
				START_Y1 = 240 - BIRD_SIZE;
				
	// NOTE: ALSO MIGHT WANT TO MOVE X OUT OF THIS MODULE TO TRACK AND INCREMENT IN UPPER MODULE
	always_ff @(posedge clk) begin
		if (reset) begin
			x <= START_X;
			y0 <= START_Y0;
			y1 <= START_Y1;
			decr_x <= 0;
		end
		else if (start) begin
			// Set a y value for the pipes first
			if (!decr_x) begin
				
				// Gap in bot half 
				if (pipe_length[9]) begin
					y0 <= 240 + (pipe_length[7:0] - 16); // range: 224 - 480
					
					// Wide gap 
					if (pipe_length[8])
						y1 <= 240 + (pipe_length[7:0] - 16) - {pipe_length[0],2'b11}*BIRD_SIZE; // range: 19 - 435
					// Normal gap
					else
						y1 <= 240 + (pipe_length[7:0] - 16) - 2*BIRD_SIZE; // range: 194-450 
				end
					
				// Gap in top half
				else begin
					y1 <= 240 - (pipe_length[7:0] - 16); // range: 0 - 256
					
					// Wide gap
					if (pipe_length[8])
						y0 <= 240 - (pipe_length[7:0] - 16) + {pipe_length[0],2'b11}*BIRD_SIZE; // range: 45 - 361
					// Normal gap		
					else
						y0 <= 240 - (pipe_length[7:0] - 16) + 2*BIRD_SIZE; // range: 30 - 286
				end
		
				// now start moving the pipe across the screen
				decr_x <= 1; 
			end
			
			// decrement x til it hits zero then we know to pick another y, i.e. start a new pipe
			else if (CLK_3HZ) begin
				if (x == 0) begin
					decr_x <= 0; // stop decrementing x
					x <= 640; // reset to front
				end	
				else
					x <= x - 1;
			end
		end
		else begin 
			// no op until start signal is set
		end
	end
	
endmodule


module pipes_testbench #(parameter N = 10, PIPE_WIDTH = 1, BIRD_SIZE = 15) ();
	logic reset, clk, start;
	logic [9:0] pipe_length;
	
	logic [N-1 : 0] x, y_top, y_bot, y0, y1;
	
	pipes #(.N(N), .PIPE_WIDTH(PIPE_WIDTH), .BIRD_SIZE(BIRD_SIZE))
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
