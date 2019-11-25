//This module is responsible for choosing coordinates to connect one 
//coordinate to another, drawing a line in the process. It takes in
//two coordinates, a clock, and reset signal and produces a coordinate
//with a digital logic.
module line_drawer(
	input logic clk, reset,
	input logic [10:0]	x0, y0, x1, y1, //the end points of the line
	output logic [10:0]	x, y, //outputs corresponding to the pair (x, y)
	output logic move
	);
	
	/*
	 * You'll need to create some registers to keep track of things
	 * such as error and direction
	 * Example: */
	logic signed [11:0] error, deltaX, deltaY, steepx, steepy, stepDirect;
	logic signed [1:0] y_step;
	logic steep;
	//The vars with leading 'w' will be the vars done with swapping and used throughout
	//the rest of the module
	logic [10:0] cx0, cx1, cy0, cy1, wx0, wx1, wy0, wy1, ctr;

	//This entire block is logic to check if y is more steep than x
	assign steepx = (x1 > x0) ? (x1 - x0) : (x0 - x1);
	assign steepy = (y1 > y0) ? (y1 - y0) : (y0 - y1);
	assign steep = steepy > steepx;
	
	//This block swaps all the necessary variables with one another for
	//further calculations
	always_comb begin
		case(steep)
			1: begin
					cx0 = y0;
					cy0 = x0;
					cx1 = y1;
					cy1 = x1;
				end
			0: begin
					cx0 = x0;
					cy0 = y0;
					cx1 = x1;
					cy1 = y1;
				end
		endcase
		case(x0 < x1)
			1: begin
					wx0 = cx0;
					wx1 = cx1;
					wy0 = cy0;
					wy1 = cy1;
				end
			0: begin
					wx0 = cx1;
					wx1 = cx0;
					wy0 = cy1;
					wy1 = cy0;
				end
		endcase
	end
	
	//Assigning deltax, deltay, and stepDirect for later use
	assign deltaX = wx1 - wx0;
	assign deltaY = (wy1 > wy0) ? (wy1 - wy0) : (wy0 - wy1);
	
	//Sets y_step based on if wy0 > wy1
	//Sets nexty to be wy or y + y_step based on error
	always_comb begin
		if (wy0 < wy1) y_step = 1;
		else y_step = -1;
	end
	

	//This block handles the actual drawing of the pixels
	always_ff @(posedge clk) begin
		//Reset starts the process of grabbing new coordinates for the 
		//calculations and initializes the counter to initial x0
		if (reset) begin
			ctr <= wx0;
			move <= 0;
		end
		//The correct x and y values are provided to the x and y variables
		//and increments the counter variable by one
		else if (ctr == wx0) begin
			if (steep) begin
				x <= wy0;
				y <= wx0;
			end
			else begin
				x <= wx0;
				y <= wy0;
			end
			error <= -(deltaX / 2);
			ctr <= ctr + 1;
		end
		//As long as the counter variable is less than x1 this block will run
		else if (ctr < wx1) begin
			//Point calculation if steep
			if (steep) begin
				y <= y + 1;
				if ((error + deltaY) >= 0) begin
					x <= x + y_step;
					error <= error - deltaX + deltaY;
				end
				else error <= error + deltaY;
			end
			//Point calculation if not steep
			else begin
				x <= x + 1;
				if ((error + deltaY) >= 0) begin
					y <= y + y_step;
					error <= error - deltaX + deltaY;
				end
				else error <= error + deltaY;
			end
			ctr <= ctr + 1;
		end
		//When the line is done drawing send a positive signal for one clock cycle
		else if (ctr == wx1) begin
			move <= 1;
			ctr <= ctr + 1;
		end
		else begin
			move <= 0;
			x <= x;
			y <= y;
		end
	end     
endmodule

//Testbench for the line_drawer module
module line_drawer_testbench();

	//Initializes logic
	logic clk, reset;
	logic [10:0] x0, y0, x1, y1, x ,y;
	
	//Sets a clock
	parameter CLOCK_PERIOD=10;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	line_drawer dut (clk, reset, x0, y0, x1, y1, x, y);
	
	//Checks to see the correctl 3x to 1y ratio is observed
	initial begin
		reset=1; x0=0; y0=0; x1=100; y1=300; #20;
		reset=0; #500;
	
		$stop;
	end
	
endmodule 