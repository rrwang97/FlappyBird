module pipes #(parameter N = 10, PIPE_WIDTH = 1, BIRD_SIZE = 15) 
			(reset, clk, pipe_length, x, y_top, y_bot, y0, y1 );
	input logic reset, clk;
	input logic [9:0] pipe_length;
	
	output logic [N-1 : 0] x, y_top, y_bot, y0, y1; // y0 should be "lower" pipe, i.e. y0 > y1
	
	parameter START_X = 640 - PIPE_WIDTH, // starts on far right of screen
				START_Y0 = 240 + BIRD_SIZE,  // gap of 2x the size of the bird
				START_Y1 = 240 - BIRD_SIZE;

	// NOTE: ALSO MIGHT WANT TO MOVE X OUT OF THIS MODULE TO TRACK AND INCREMENT IN UPPER MODULE
	always_ff @(posedge clk) begin
		if (reset) begin
			x <= START_X;
			y0 <= START_Y0;
			y1 <= START_Y1;
		end
		else if (pipe_length[9]) begin
			y0 <= 240 + (pipe_length[7:0] - 16); // range: 224 - 480
			if (pipe_length[8])
				y1 <= 240 + (pipe_length[7:0] - 16) - {pipe_length[0],2'b11}*BIRD_SIZE; // range: 19 - 435
			else
				y1 <= 240 + (pipe_length[7:0] - 16) - 2*BIRD_SIZE; // range: 194-450 
		end
		else
			y1 <= 240 - (pipe_length[7:0] - 16); // range: 0 - 256
			if (pipe_length[8])
				y0 <= 240 - (pipe_length[7:0] - 16) + {pipe_length[0],2'b11}*BIRD_SIZE; // range: 45 - 361
			else
				y0 <= 240 - (pipe_length[7:0] - 16) + 2*BIRD_SIZE; // range: 30 - 286
	end
	
	assign y_top = '0;
	assign y_bot = 480;
	
endmodule

// 480 = 9'b1_1111_0000