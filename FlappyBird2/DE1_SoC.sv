module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW,
					 CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS,
					 PS2_DAT, PS2_CLK);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	
	input logic PS2_DAT, PS2_CLK;

	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;

	logic reset;
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;
	logic [9:0] pipe_length;
	logic [9:0] bird_x0, bird_x1, pipe1_x0, pipe1_x1, pipe2_x0, pipe2_x1, pipe3_x0, pipe3_x1; 
	logic [8:0] bird_y0, bird_y1, pipe1_y0, pipe1_y1, pipe2_y0, pipe2_y1, pipe3_y0, pipe3_y1;
	logic start, start1, start2, start3, start_bird, game_over;
	logic [6:0] score;
	logic [7:0] outCode;
	logic makeBreak, valid, flap;
	
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	assign reset = ~KEY[3];//SW[9]; 
	assign start = ~KEY[0];
	assign LEDR[0] = game_over;
	
	video_driver #(.WIDTH(640), .HEIGHT(480))
		v1 (.CLOCK_50, .reset(~KEY[2]), .x, .y, .r, .g, .b,
			 .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
			 .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);
	
	// RGB control logic		
	always_ff @(posedge CLOCK_50) begin
		// clear screen
		if (reset || game_over) begin
			r = 255;	
			g = 255;
			b = 255;
		end
		// draw pipe 1
		else if (x >= pipe1_x0 && x <= pipe1_x1 && (y >= pipe1_y0 || y <= pipe1_y1)) begin
			r = 0;	
			g = 255;
			b = 0;
		end
		// draw pipe 2
		else if (x >= pipe2_x0 && x <= pipe2_x1 && (y >= pipe2_y0 || y <= pipe2_y1)) begin
			r = 0;	
			g = 255;
			b = 0;
		end
		// draw pipe 3
		else if (x >= pipe3_x0 && x <= pipe3_x1 && (y >= pipe3_y0 || y <= pipe3_y1)) begin
			r = 0;	
			g = 255;
			b = 0;
		end
		// draw bird
		else if (x >= bird_x0 && x <= bird_x1 && y >= bird_y0 && y <= bird_y1) begin
			r = 255;	// google rgb to hex
			g = 0;
			b = 0;
		end
		// draw white spaces
		else begin
			r = 255;	
			g = 255;
			b = 255;
		end
	end

	//		BIRD	 	  PIPE	      
	//	y1 ___  	 	 |    |		
	//	  |   |	 y1 |____|		  
	//	y0|___|										
	//	 x0	x1	 y0  ____		  
	//			   	 |	   |	
	//			 		 |    |
	//			  		x0	  x1
	
	// Control logic to start drawing pipes and bird movement
	always_ff @(posedge CLOCK_50) begin
		if (reset || game_over) begin
			start1 <= 0;
			start2 <= 0;
			start3 <= 0;
		end 
		// draw pipe 1 and bird movement
		else if (start) begin
			start1 <= 1;
			start_bird <= 1;
		end 
		// draw pipe 2 after pipe 1 is 1/3 of the screen
		else if (start1 && (pipe1_x0 == 213)) begin
			start2 <= 1;
		end
		// draw pipe 3 after pipe 2 is 1/3 of the screen
		else if (start2 && (pipe2_x0 == 213)) begin
			start3 <= 1;
		end	

		// Can start the bird movement independent of the pipes
		if (reset)
			start_bird <= 0;
		else if (~KEY[1])
			start_bird <= 1;
	end

//****** PIPES ********//
	LFSR_10Bit randomizer (.reset, .clk(CLOCK_50), .Q(pipe_length));
			 
	pipes pipe1 (.reset, .clk(CLOCK_50), .start(start1), .pipe_length,   
					.x0(pipe1_x0), .x1(pipe1_x1), .y0(pipe1_y0), .y1(pipe1_y1));
	
	pipes pipe2 (.reset, .clk(CLOCK_50), .start(start2), .pipe_length,  
					.x0(pipe2_x0), .x1(pipe2_x1), .y0(pipe2_y0), .y1(pipe2_y1));
	
	pipes pipe3 (.reset, .clk(CLOCK_50), .start(start3), .pipe_length, 
					.x0(pipe3_x0), .x1(pipe3_x1), .y0(pipe3_y0), .y1(pipe3_y1));
					
//***** BIRD ********//
	userInput spacebar (.reset, .clk(CLOCK_50), .in((outCode == 8'h29) && makeBreak), .out(flap));
	
	keyboard_press_driver spacebar_input(.reset, .CLOCK_50, .outCode, .makeBreak, .valid, .PS2_DAT, .PS2_CLK);
	
	bird birdy (.reset, .clk(CLOCK_50), .start(start_bird),
					.flap, .x0(bird_x0), .y0(bird_y0));				
	// assign 2nd coord set to make bird a square
	assign bird_x1 = bird_x0 + 15; 
	assign bird_y1 = bird_y0 + 15;	

//***** SCORE *******//
	CollisionDetection scoreCounter
			(.reset(start || reset), .clk(CLOCK_50), .bird_x0, .bird_x1, .pipe1_x0, .pipe1_x1, .pipe2_x0, .pipe2_x1, 
			.pipe3_x0, .pipe3_x1, .bird_y0, .bird_y1, .pipe1_y0, .pipe1_y1, .pipe2_y0, .pipe2_y1, 
			.pipe3_y0, .pipe3_y1, .score, .game_over);
			
	DisplayScore hexdisplay (.score, .HEX0, .HEX1);
	
endmodule


module DE1_SoC_testbench();
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	
	logic PS2_DAT, PS2_CLK;

	logic CLOCK_50;
	logic [7:0] VGA_R;
	logic [7:0] VGA_G;
	logic [7:0] VGA_B;
	logic VGA_BLANK_N;
	logic VGA_CLK;
	logic VGA_HS;
	logic VGA_SYNC_N;
	logic VGA_VS;
	
	DE1_SoC dut (.*);
	
	initial begin
		CLOCK_50 <= 0;
		forever #(10/2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin
		KEY[3] <= 0; #10;
		KEY[3] <= 1; #10; // reset
		repeat(3) 	 #10;
		
		KEY[1] <= 0; #10;
		KEY[1] <= 1; #10; // start just the bird
		repeat(10)	 #10; 
	
		KEY[0] <= 0; #10;
		KEY[0] <= 1; #10; // start game
		repeat(10)	 #10; 
	
	
	
		$stop;
	end

endmodule
