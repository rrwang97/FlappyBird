// GIVE A 12 HZ clock
module CollisionDetection #(parameter N = 11)
			(reset, clk, bird_x, bird_y0, bird_y1,
			pipe1_x, pipe1_y0, pipe1_y1, 
			pipe2_x, pipe2_y0, pipe2_y1,
			pipe3_x, pipe3_y0, pipe3_y1, 
			score, game_over);
			
	input logic reset, clk;
	input logic [N-1 : 0] bird_x, bird_y0, bird_y1,
								 pipe1_x, pipe1_y0, pipe1_y1, 
								 pipe2_x, pipe2_y0, pipe2_y1,
								 pipe3_x, pipe3_y0, pipe3_y1;
	output logic [6:0] score;
	output logic game_over;
	
	// when the x coord of the bird and pipe match, check y coords for collision
	always_ff @(posedge clk) begin
		if (reset) begin
			score <= '0;
			game_over <= 0; 
		end
		else if (game_over) begin
			score <= '0;
			game_over <= 0; 
		end
		else begin
			case (bird_x) 
				pipe1_x:	if ((bird_y0 < pipe1_y0) && (bird_y1 > pipe1_y1)) 
								score <= score + 1;
							else
								game_over = 1;
				pipe2_x:	if ((bird_y0 < pipe2_y0) && (bird_y1 > pipe2_y1)) 
								score <= score + 1;
							else
								game_over = 1;
				pipe3_x:	if ((bird_y0 < pipe3_y0) && (bird_y1 > pipe3_y1)) 
								score <= score + 1;
							else
								game_over = 1;
				default: ;
			endcase
		end
	end

endmodule

module CollisionDetection_testbench #(parameter N = 10) ();
	logic reset, clk;
	logic [N-1 : 0] bird_x, bird_y0, bird_y1,
								 pipe1_x, pipe1_y0, pipe1_y1, 
								 pipe2_x, pipe2_y0, pipe2_y1,
								 pipe3_x, pipe3_y0, pipe3_y1;
	logic [6:0] score;
	logic game_over;
	
	CollisionDetection #(.N(N)) dut (.*);
	
	initial begin
		clk <= 0;
		forever #(10/2) clk <= ~clk;
	end
	
	initial begin
		bird_x <= 0; bird_y0 <= 7; bird_y1 <= 3;
	
		reset <= 1; #10;
		reset <= 0; #10;
		pipe1_x <= 0; pipe1_y0 <= 8; pipe1_y1 <= 2; #10; // should incr score
		pipe1_x <= 0; pipe1_y0 <= 7; pipe1_y1 <= 2; #10; // game over
		pipe1_x <= 0; pipe1_y0 <= 8; pipe1_y1 <= 3; #10; // game over
		pipe1_x <= 0; pipe1_y0 <= 7; pipe1_y1 <= 3; #10; // game over
		pipe1_x <= 1; #10; 
		
		repeat(10) #10;
		
		pipe2_x <= 0; pipe2_y0 <= 8; pipe2_y1 <= 2; #10; // should incr score
		pipe2_x <= 0; pipe2_y0 <= 7; pipe2_y1 <= 2; #10; // game over
		pipe2_x <= 0; pipe2_y0 <= 8; pipe2_y1 <= 3; #10; // game over
		pipe2_x <= 0; pipe2_y0 <= 7; pipe2_y1 <= 3; #10; // game over
		pipe2_x <= 1; #10; 
		
		repeat(10) #10;
		
		pipe3_x <= 0; pipe3_y0 <= 8; pipe3_y1 <= 2; #10; // should incr score
		pipe3_x <= 0; pipe3_y0 <= 7; pipe3_y1 <= 2; #10; // game over
		pipe3_x <= 0; pipe3_y0 <= 8; pipe3_y1 <= 3; #10; // game over
		pipe3_x <= 0; pipe3_y0 <= 7; pipe3_y1 <= 3; #10; // game over
		pipe3_x <= 1; #10; 
	
		$stop;
	end	
endmodule
