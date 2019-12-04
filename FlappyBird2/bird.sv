// Module used to track the position of the bird
// Inputs: reset, clk(CLOCK_50MHz), start signal ie start moving the bird, flap ie bird flies up 
// Outputs: (x0, y0) coord pair of the top left corner of the bird
module bird #(parameter BIRD_SIZE = 15)(reset, clk, start, flap, x0, y0);
	input logic reset, clk, start;
	input logic flap; // moves bird up
	
	output logic [9:0] x0;
	output logic [8:0] y0;
	
	parameter START_X0 = 160, 
				START_Y0 = 240,
				GRAVITY_CONST = 2, GRAVITY_ACCEL = 2,
				FLY_UP = 25;
	
	logic [9 :0] gravity; // to track acceleration
	logic CLK_12HZ;
	logic [31 : 0] divided_clk; // used to slow down falling bc user can't input fast enough to ever beat a 50MHz clk
									 // Realistically a person can press space 8-9 times per sec
									 // 50MHz / 6.25M = 8 Hz 
									 // divided_clk[0] = 25MHz, [1] = 12.5Mhz, ... [21] = 12Hz, [22] = 6Hz
	
	// Counter for the divided clk
	always_ff @(posedge clk) begin
		if (reset) 
			divided_clk <= '0;
		else
			divided_clk <= divided_clk + 1;
	end
	
	// Makes sure CLK_12Hz is high for 1 cycle -- for testbench use divided_clk[1] a faster clock
	userInput dividedclk (.reset, .clk, .in(divided_clk[1]), .out(CLK_12HZ));
									
	always_ff @(posedge clk) begin
		if (reset) begin		// starting position
			x0 <= START_X0;		
			y0 <= START_Y0;
			gravity <= GRAVITY_CONST;
		end
		// start tracking bird coords
		else if (start) begin
			if (flap) begin // fly up
				gravity <= GRAVITY_CONST; // reset gravity acceleration
				x0 <= x0;
				if (signed'(y0 - FLY_UP) > 0) begin // not at top border then fly up
					y0 <= y0 - FLY_UP;
				end 
				else if (signed'(y0 - BIRD_SIZE - FLY_UP) <= 0) begin // hit the top border
					y0 <= 0;
				end
			end	
			// fall down at a slower rate 
			else if (CLK_12HZ) begin	// fall down
				gravity <= gravity + GRAVITY_ACCEL; // increase amount you fall by
				x0 <= x0;
				if ((y0 + gravity) < 480) begin // fall if not at bottom
					y0 <= y0 + gravity;
				end 
				else begin	// hit bottom border
					y0 <= y0;
				end
			end
		end
		else begin // reset coords again if not in start or reset
			x0 <= START_X0;		
			y0 <= START_Y0;
			gravity <= GRAVITY_CONST;
		end
	end
endmodule

module bird_testbench #(BIRD_SIZE = 15) ();
	logic reset, clk, start;
	logic flap;
	logic [9:0] x0;
	logic [8:0] y0;
	
	bird #(.BIRD_SIZE(BIRD_SIZE)) dut (.*);
	
	parameter CLOCK_PERIOD = 10;
	initial begin
		clk <= 0; 
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	// Not tested with divided_clk bc that would have too many waveforms 
	initial begin
		flap <= 0; start <= 1; 
		reset <= 1; #10;
		reset <= 0; #10;
		repeat(10)  #10; // falls down = Ys should be increasing
		start <= 0;
		flap <= 1; 
		repeat(3)  #10; // wait for start
		start <= 1; #10;	// flys up = Ys should be decreasing
		repeat(10);
		flap <= 0; 
		reset <= 1; #10;
		reset <= 0; #10;
		repeat(245) #10; // test bottom border
		flap <= 1; 
		repeat(485) #10; // test top border
		
		$stop;
	end


endmodule
