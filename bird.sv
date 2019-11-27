module bird #(parameter N = 10, BIRD_SIZE = 15)(reset, clk, flap, x0, y0, x1, y1);
	input logic reset, clk;
	input logic flap; // moves bird up
	
	output logic [N-1 : 0] x0, y0, x1, y1;
	
	parameter START_X = 160,
				START_Y0 = 240 + BIRD_SIZE/2,
				START_Y1 = 240 - BIRD_SIZE/2,
				GRAVITY_CONST = 2, GRAVITY_ACCEL = 2,
				FLY_UP = 10;
	
	logic [N-1 :0] gravity; // to track acceleration
	
	logic [31 : 0] divided_clk; // used to slow down falling bc user can't input fast enough to ever beat a 50MHz clk
									 // Realistically a person can press space 8-9 times per sec
									 // 50MHz / 6.25M = 8 Hz 
									 // divided_clk[0] = 25MHz, [1] = 12.5Mhz, ... [21] = 12Hz, [22] = 6Hz
									
	always_ff @(posedge clk) begin
		if (reset) begin		// starting position
			x0 <= START_X;		
			x1 <= START_X;
			y0 <=  START_Y0;
			y1 <=  START_Y1;
			gravity <= GRAVITY_CONST;
			divided_clk <= '0;
		end
		else if (flap) begin // fly up
			gravity <= GRAVITY_CONST; // reset gravity acceleration
			divided_clk <= '0;		  // SO the bird doesnt fall right after going up
			x0 <= x0;
			x1 <= x1;
			if (y1 > 0) begin // hit the top border
				y0 <= y0 - FLY_UP;
				y1 <= y1 - FLY_UP;
			end 
			else begin
				y0 <= y0;
				y1 <= y1;
			end
		end
		else if (divided_clk == (32'b1 << 21)) begin				// fall down
			gravity <= gravity ** GRAVITY_ACCEL; // increase amount you fall by
			x0 <= x0;
			x1 <= x1;
			if (y0 < 480) begin // hit bottom border
				y0 <= y0 + gravity;
				y1 <= y1 + gravity;
			end
			else begin
				y0 <= y0;
				y1 <= y1;
			end
		end
		else begin
			divided_clk <= divided_clk + 1;
		end
	end

endmodule

module bird_testbench #(parameter N = 10, BIRD_SIZE = 15) ();
	logic reset, clk;
	logic flap;
	logic [N-1 : 0] x0, y0, x1, y1;
	
	bird #(.N(N), .BIRD_SIZE(BIRD_SIZE)) dut (.*);
	
	parameter CLOCK_PERIOD = 10;
	initial begin
		clk <= 0; 
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	// Not tested with divided_clk bc that would have too many waveforms 
	initial begin
		flap <= 0;
		reset <= 1; #10;
		reset <= 0; #10;
		repeat(10)  #10; // falls down = Ys should be increasing
		flap <= 1; 
		repeat(10)  #10; // flys up = Ys should be decreasing
		flap <= 0; 
		repeat(245) #10; // test bottom border
		flap <= 1; 
		repeat(485) #10; // test top border
		
		$stop;
	end


endmodule
