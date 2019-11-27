module bird #(parameter N = 10, BIRD_SIZE = 15)(reset, clk, flap, x0, y0, x1, y1);
	input logic reset, clk;
	input logic flap; // moves bird up
	
	output logic [N-1 : 0] x0, y0, x1, y1;
	
	parameter START_X = 160,
				START_Y0 = 240 - BIRD_SIZE/2,
				START_Y1 = 240 + BIRD_SIZE/2;
	
	// MIGHT REMOVE X FROM HERE BC IT IS A CONSTANT SINCE THE BIRD NEVER MOVES "HORIZONTALLY"
	
	always_ff @(posedge clk) begin
		if (reset) begin		// starting position
			x0 <= START_X;		
			x1 <= START_X;
			y0 <=  START_Y0;
			y1 <=  START_Y1;
		end
		else if (flap) begin // fly up
			x0 <= x0;
			x1 <= x1;
			if (y0 > 0) begin // hit the top border
				y0 <= y0 - 1;
				y1 <= y1 - 1;
			end 
			else begin
				y0 <= y0;
				y1 <= y1;
			end
		end
		else begin				// fall down			
			x0 <= x0;
			x1 <= x1;
			if (y1 < 480) begin
				y0 <= y0 + 1;
				y1 <= y1 + 1;
			end
			else begin
				y0 <= y0;
				y1 <= y1;
			end
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
