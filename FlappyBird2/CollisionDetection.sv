// GIVE A 12 HZ clock
module CollisionDetection #(parameter N = 11)
			(reset, clk, bird_x0, bird_x1, pipe1_x0, pipe1_x1, pipe2_x0, pipe2_x1, pipe3_x0, pipe3_x1,
			bird_y0, bird_y1, pipe1_y0, pipe1_y1, pipe2_y0, pipe2_y1, pipe3_y0, pipe3_y1,
			score, game_over);
			
	input logic reset, clk;
	input logic [9:0] bird_x0, bird_x1, pipe1_x0, pipe1_x1, pipe2_x0, pipe2_x1, pipe3_x0, pipe3_x1; 
	input logic [8:0] bird_y0, bird_y1, pipe1_y0, pipe1_y1, pipe2_y0, pipe2_y1, pipe3_y0, pipe3_y1;
								 
	//		BIRD	 	  PIPE	      
	//	y1 ___  	 	 |    |		
	//	  |   |	 y1 |____|		  
	//	y0|___|										
	//	 x0	x1	 y0  ____		  
	//			   	 |	   |	
	//			 		 |    |
	//			  		x0	  x1

		
	
	output logic [6:0] score;
	output logic game_over;
	
	// a flag to make sure we only incr score only once per pipe
	logic space1, space2, space3, increment;
	assign space1 = (bird_x0 >= pipe1_x1) && (bird_x0 <= pipe2_x0); // bird in btwn pipe1 and pipe2
	assign space2 = (bird_x0 >= pipe2_x1) && (bird_x0 <= pipe3_x0); // bird in btwn pipe2 and pipe3
	assign space3 = (bird_x0 >= pipe3_x1) && (bird_x0 <= pipe1_x0); // bird in btwn pipe3 and pipe1
	
	// when the x coord of the bird and pipe match, check y coords for collision
	always_ff @(posedge clk) begin
		if (reset) begin
			score <= '0;
			game_over <= 0; 
		end
		else begin
			// if bird is in btwn pipe1 x bounds, check if y bounds overlap
			if (bird_x1 >= pipe1_x0 && bird_x0 <= pipe1_x1) begin
				if ((bird_y0 >= pipe1_y0) || (bird_y1 <= pipe1_y1)) begin
					game_over <= 1; // if overlap, game over	
				end
			end
			// if bird is in btwn pipe2 x bounds, check if y bounds overlap
			else if (bird_x1 >= pipe2_x0 && bird_x0 <= pipe2_x1) begin
				if ((bird_y0 >= pipe2_y0) || (bird_y1 <= pipe2_y1)) begin
					game_over <= 1;	
				end
			end
			// if bird is in btwn pipe3 x bounds, check if y bounds overlap
			else if (bird_x1 >= pipe3_x0 && bird_x0 <= pipe3_x1) begin
				if ((bird_y0 >= pipe3_y0) || (bird_y1 <= pipe3_y1)) begin
					game_over <= 1;	
				end
			end

		end
		if (increment) begin 
			score <= score + 1; 
		end
	end

	// When the bird moves from one space to the next successfully then increment score ONCE per change
	userInput incr (.clk(clk), .reset(reset), .in(space1 || space2 || space3), .out(increment));

endmodule


module CollisionDetection_testbench #(parameter N = 10) ();
	logic reset, clk;
	logic [N-1 : 0] bird_x0, bird_x1, pipe1_x0, pipe1_x1, pipe2_x0, pipe2_x1, pipe3_x0, pipe3_x1;
	logic [8:0] bird_y0, bird_y1, pipe1_y0, pipe1_y1, pipe2_y0, pipe2_y1, pipe3_y0, pipe3_y1;
	logic [6:0] score;
	logic game_over;
	
	CollisionDetection #(.N(N)) dut (.*);
	
	initial begin
		clk <= 0;
		forever #(10/2) clk <= ~clk;
	end
	
	initial begin
		bird_y0 <= 20; bird_y1 <= 0;
		pipe1_x0 = 50; pipe1_x1 = 60; pipe1_y0 = 300; pipe1_y1 = 200;
		pipe2_x0 = 70; pipe2_x1 = 80; pipe2_y0 = 300; pipe2_y1 = 200;
		pipe3_x0 = 90; pipe3_x1 = 100; pipe3_y0 = 300; pipe3_y1 = 200;
		reset <= 1; #10;
		reset <= 0; #10;
		for (int i=0; i < 15; i++) begin
			bird_x0 = i * 10;
			bird_x1 = i * 10 + 10; #10;
		end
		
		
		$stop;
	end	
endmodule