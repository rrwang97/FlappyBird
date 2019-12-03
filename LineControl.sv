module LineControl #(parameter N = 11) (clk, reset, pipe1_x, pipe1_y0, pipe1_y1,
												pipe2_x, pipe2_y0, pipe2_y1,
												pipe3_x, pipe3_y0, pipe3_y1,
												y_top, y_bot, 
												bird_x, bird_y0, bird_y1, 
												x0, y0, x1, y1, line_done, clear_done, cycle_done);
	
	input logic clk, reset, line_done, clear_done;
	input logic [N-1:0] pipe1_x, pipe1_y0, pipe1_y1,
					pipe2_x, pipe2_y0, pipe2_y1,
					pipe3_x, pipe3_y0, pipe3_y1,
					y_top, y_bot, 
					bird_x, bird_y0, bird_y1;

	output logic [N-1:0] x0, y0, x1, y1;
	output logic cycle_done;
	
	enum {pipe1_top, pipe1_bot, pipe2_top, pipe2_bot, pipe3_top, pipe3_bot, bird, clear} ns, ps;
	
	always_ff @(posedge clk) begin
		if (reset) begin
			ps <= pipe1_bot;
		end
		else begin
			ps <= ns;
		end
	end
	
	always_comb begin
		case(ps)
			pipe1_top: 	begin
								x0 = pipe1_x; y0 = y_top;
								x1 = pipe1_x; y1 = pipe1_y1;
								
								if (line_done) ns = pipe1_bot;
								else ns = pipe1_top;
							end
			pipe1_bot:	begin
								x0 = pipe1_x; y0 = y_bot;
								x1 = pipe1_x; y1 = pipe1_y0;
								
								if (line_done) ns = pipe2_top;
								else ns = pipe1_bot;
							end
			pipe2_top:	begin
								x0 = pipe2_x; y0 = y_top;
								x1 = pipe2_x; y1 = pipe2_y1;
								
								if (line_done) ns = pipe2_bot;
								else ns = pipe2_top;
							end
			pipe2_bot:	begin
								x0 = pipe2_x; y0 = y_bot;
								x1 = pipe2_x; y1 = pipe2_y0;
								
								if (line_done) ns = pipe3_top;
								else ns = pipe2_bot;
							end
			pipe3_top:	begin
								x0 = pipe3_x; y0 = y_top;
								x1 = pipe3_x; y1 = pipe3_y1;
								
								if (line_done) ns = pipe3_bot;
								else ns = pipe3_top;
							end
			pipe3_bot:	begin
								x0 = pipe3_x; y0 = y_bot;
								x1 = pipe3_x; y1 = pipe3_y0;
								
								if (line_done) ns = bird;
								else ns = pipe3_bot;
							end
			bird:	begin
						x0 = bird_x; y0 = bird_y0;
						x1 = bird_x; y1 = bird_y1;
						
						if (line_done) ns = clear;
						else ns = bird;
					end
			clear:	if (clear_done) ns = pipe1_top;
						else ns = clear;
			default: begin
						x0 = 0; y0 = 0;
						x1 = 0; y1 = 0;
						ns = pipe1_top;
						end
		endcase
	end
	
	assign cycle_done = (ps == clear);
	
	endmodule 