//Top level file to combine logic from all modules to create the working product.
//Has VGA output so it is possible to draw on the screen
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS, PS2_DAT, PS2_CLK);
	
	//Initializes all logic
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	input logic PS2_DAT, PS2_CLK;

	//Sets all 7 seg displays to be off
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	assign LEDR = SW;
	
	//Reset is assigned to switch 9
	assign reset = SW[9];

	logic [10:0] clr_x, clr_y, line_x, line_y, x, y, 
					x0, y0, x1, y1,
					pipe1_x, pipe1_y0, pipe1_y1,
					pipe2_x, pipe2_y0, pipe2_y1,
					pipe3_x, pipe3_y0, pipe3_y1,
					y_top, y_bot, //top and bottom of the screen
					bird_x, bird_y0, bird_y1;
	
	logic [9:0] pipe_length;
	logic [7:0] outCode;
	logic [6:0] score;
	logic makeBreak, valid, flap, game_over, color;
	logic line_done, clear_done, cycle_done;

//******** PIPES & BIRD COORDS ***********//
	assign y_top = '0;
	assign y_bot = 480;
	
	LFSR_10Bit randomizer (.reset, .clk(CLOCK_50), .Q(pipe_length));
	
	pipes #(.START_X(640)) pipe1 (.reset, .clk(CLOCK_50), .start(1), .pipe_length, .x(pipe1_x), .y0(pipe1_y0), .y1(pipe1_y1));
	pipes #(.START_X(440)) pipe2 (.reset, .clk(CLOCK_50), .start(1), .pipe_length, .x(pipe2_x), .y0(pipe2_y0), .y1(pipe2_y1));
	pipes #(.START_X(240)) pipe3 (.reset, .clk(CLOCK_50), .start(1), .pipe_length, .x(pipe3_x), .y0(pipe3_y0), .y1(pipe3_y1));
	
	userInput spacebar (.reset, .clk(CLOCK_50), .in((outCode == 8'h29) && makeBreak), .out(flap));
	
	keyboard_press_driver spacebar_input(.reset, .CLOCK_50, .outCode, .makeBreak, .valid, .PS2_DAT, .PS2_CLK);
	
	bird birdy (.reset, .clk(CLOCK_50), .flap, .x0(bird_x), .y0(bird_y0), .y1(bird_y1));
	
//******* Score *******//
	CollisionDetection hit (.reset, .clk(CLOCK_50), .pipe1_x, .pipe1_y0, .pipe1_y1,
					.pipe2_x, .pipe2_y0, .pipe2_y1, .pipe3_x, .pipe3_y0, .pipe3_y1,
					.bird_x, .bird_y0, .bird_y1, .score, .game_over);
					
	DisplayScore points (.score, .HEX0, .HEX1);

//******** Line Control logic ********//
	LineControl chooseLine (.clk(CLOCK_50), .reset, .pipe1_x, .pipe1_y0, .pipe1_y1, .pipe2_x, .pipe2_y0, .pipe2_y1,
										.pipe3_x, .pipe3_y0, .pipe3_y1, .y_top, .y_bot, 
										.bird_x, .bird_y0, .bird_y1, .x0, .y0, .x1, .y1, 
										.line_done, .clear_done, .cycle_done);
										
	line_drawer drawLines (.clk(CLOCK_50), .reset(reset), .x0, .y0, .x1, .y1, .x(line_x), .y(line_y), .move(line_done));
		
	clearScreen clearshit (.clk(CLOCK_50), .reset, .start(cycle_done), .x(clr_x), .y(clr_y), .done(clear_done));
	
//******** VGA *************//
	assign x = cycle_done ? clr_x : line_x;
	assign y = cycle_done ? clr_y : line_y;
	assign color = cycle_done ? 0 : 1;
	
	VGA_framebuffer fb(.clk50(CLOCK_50), .reset, .x, .y,
				.pixel_color(color), .pixel_write(1'b1),
				.VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
				.VGA_BLANK_n(VGA_BLANK_N), .VGA_SYNC_n(VGA_SYNC_N));

endmodule
	
/*

//Top level file to combine logic from all modules to create the working product.
//Has VGA output so it is possible to draw on the screen
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS, PS2_DAT, PS2_CLK);
	
	//Initializes all logic
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	input logic PS2_DAT, PS2_CLK;
	
	//Sets all 7 seg displays to be off
//	assign HEX0 = '1;
//	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	assign LEDR = SW;
	
	//Instantiates internal logic
	logic [10:0] x0, y0, x1, y1, x, y, clrX, clrY;
	logic [10:0] lineX, lineY, bx0, by0, bx1, by1, inx0, iny0, inx1, iny1;
	logic [10:0] pipe1_x, pipe1_y0, pipe1_y1,
					pipe2_x, pipe2_y0, pipe2_y1,
					pipe3_x, pipe3_y0, pipe3_y1,
					y_top, y_bot, //top and bottom of the screen
					bird_x, bird_y0, bird_y1;
	logic [7:0] sizex0, sizey0, sizex1, sizey1;
	logic color, move, clk, lineColor, clearColor, writeFifo, memRead;
	logic emptyx0, emptyy0, emptyx1, emptyy1, fullx0, fully0, fullx1, fully1;
	logic reset, clear, wr, empty;
	
	logic [17:0] cnt;
	
	//Reset is assigned to switch 9
	assign reset = SW[9];
	
	logic [9:0] pipe_length;
	logic [7:0] outCode;
	logic [6:0] score;
	logic makeBreak, valid, flap, game_over;
	
	assign y_top = '0;
	assign y_bot = 480;
	
	LFSR_10Bit randomizer (.reset, .clk(CLOCK_50), .Q(pipe_length));
	
	pipes #(.START_X(640)) pipe1 (.reset, .clk(CLOCK_50), .start(1), .pipe_length, .x(pipe1_x), .y0(pipe1_y0), .y1(pipe1_y1));
	pipes #(.START_X(440)) pipe2 (.reset, .clk(CLOCK_50), .start(1), .pipe_length, .x(pipe2_x), .y0(pipe2_y0), .y1(pipe2_y1));
	pipes #(.START_X(240)) pipe3 (.reset, .clk(CLOCK_50), .start(1), .pipe_length, .x(pipe3_x), .y0(pipe3_y0), .y1(pipe3_y1));
	
	userInput spacebar (.reset, .clk(CLOCK_50), .in((outCode == 8'h29) && makeBreak), .out(flap));
	
	keyboard_press_driver spacebar_input(.reset, .CLOCK_50, .outCode, .makeBreak, .valid, .PS2_DAT, .PS2_CLK);
	
	bird birdy (.reset, .clk(CLOCK_50), .flap, .x0(bird_x), .y0(bird_y0), .y1(bird_y1));
	
	CollisionDetection hit (.reset, .clk(CLOCK_50), .pipe1_x, .pipe1_y0, .pipe1_y1,
					.pipe2_x, .pipe2_y0, .pipe2_y1, .pipe3_x, .pipe3_y0, .pipe3_y1,
					.bird_x, .bird_y0, .bird_y1, .score, .game_over);
					
	DisplayScore points (.score, .HEX0, .HEX1);
	
	//Clock divider
	always_ff @(posedge CLOCK_50) begin
		if (reset) cnt <= 0;
		else cnt <= cnt + 1;
		if (cnt == 18'b111111111111111111) clk = 1;
		else clk = 0;
	end
	
	//Variables to be sent to the framebuffer change depending on
	//If the screen should be cleared or not
	assign x = SW[8] ? clrX : lineX;
	assign y = SW[8] ? clrY : lineY;
	assign color = SW[8] ? clearColor : lineColor;
	
	//In charge of all the pixels
	VGA_framebuffer fb(.clk50(CLOCK_50), .reset(1'b0), .x, .y,
				.pixel_color(color), .pixel_write(1'b1),
				.VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
				.VGA_BLANK_n(VGA_BLANK_N), .VGA_SYNC_n(VGA_SYNC_N));
				
	//draws lines based on coordinate values 
	line_drawer lines (.clk(clk), .reset(reset),
				.x0, .y0, .x1, .y1, .x(lineX), .y(lineY), .move(move));
				
	//Counter that covers all pixel coordinates			
	clearScreen clr (.start(clear), .reset(reset), .clk(CLOCK_50),
						  .x(clrX), .y(clrY), .color(clearColor));
	
	BufferControl bcontrol (clock, reset, pipe1_x, pipe1_y0, pipe1_y1,
					pipe2_x, pipe2_y0, pipe2_y1,
					pipe3_x, pipe3_y0, pipe3_y1,
					y_top, y_bot, 
					bird_x, bird_y0, bird_y1, bx0, by0, bx1, by1, wr, clearScreen);
					 
	userInput writeSignal (.clk(clk), .reset(reset), .in(wr), .out(writeFifo));
					  
	FrameBufferFeed feeder (clk, reset, empty, inx0, iny0, inx1, iny1, x0, y0, x1, y1, memRead);
	
	
	//Need to create a write signal that is not true all the time or else fifo will be filled
	//Fifo to hold x0 values
	memory memx0 (.clock(CLOCK_50), .data(bx0), .rdreq(memRead), .sclr(reset), .wrreq(writeFifo), .empty(emptyx0),
					  .full(fullx0), .q(inx0), .usedw(sizex0));
	//Fifo to hold y0 values				  
	memory memy0 (.clock(CLOCK_50), .data(by0), .rdreq(memRead), .sclr(reset), .wrreq(writeFifo), .empty(emptyy0),
					  .full(fully0), .q(iny0), .usedw(sizey0));
	//Fifo to hold x1 values	  
	memory memx1 (.clock(CLOCK_50), .data(bx1), .rdreq(memRead), .sclr(reset), .wrreq(writeFifo), .empty(emptyx1),
					  .full(fullx1), .q(inx1), .usedw(sizex1));
	//Fifo to hold y1 values				  
	memory memy1 (.clock(CLOCK_50), .data(by1), .rdreq(memRead), .sclr(reset), .wrreq(writeFifo), .empty(emptyy1),
					  .full(fully1), .q(iny1), .usedw(sizey1));
	
endmodule

*/

//Testbench for DE1_SoC
module DE1_SoC_testbench();
	
	//Instantiates all logic
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic clk, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS;
	logic [7:0] VGA_R;
	logic [7:0] VGA_G;
	logic [7:0] VGA_B;
	
	//Sets clock period
	parameter CLOCK_PERIOD=10;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	DE1_SoC dut (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, clk, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	
	//Checks to see the correct x,y coordinates are being processed
	//and clearScreen functions properly
	initial begin
		SW[9]=1; SW[8]=0; #10;
		SW[9]=0; #10;
		#10000000;
		$stop;
	end
	
endmodule 
