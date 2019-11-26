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
			y0 <=  START_Y0;
			x1 <= START_X;
			y1 <=  START_Y1;
		end
		else if (flap) begin // fly up
			x0 <= x0;
			y0 <= y0 - 1;
			x1 <= x1;
			y1 <= y1 - 1;
		end
		else begin				// fall down			
			x0 <= x0;
			y0 <= y0 + 1;
			x1 <= x1;
			y1 <= y1 + 1;
		end
	end

endmodule
