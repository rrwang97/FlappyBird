//clearScreen outputs all possible coordinates for 640x480
//and sets the color to 1'b0 to clear the screen
module clearScreen (input logic start, reset, clk,
						  output logic [10:0] x, y,
						  output logic color
						  );
	logic [10:0] nx=0, ny=0;
						  
	//Counter that scrolls through every pixel point
	//in a 640x480 screen
	always_comb begin
		color = 0;
		if (x < 640 && y == 480) nx = x + 1;
		else if (x >= 640) nx = 0;
		else nx = x;
		if (y < 480) ny = y + 1;
		else ny = 0;
	end			  
	
	//Logic for what x and y values will be next
	always_ff @(posedge clk) begin
		if (reset) begin x <= 0; y <= 0; end
		else if (start) begin x <= nx; y <= ny; end
		else begin x <= 0; y <= 0; end
	end
						  					  
endmodule					

//Testbench for clearScreen module
module clearScreen_testbench();
	
	//Logic initialized
	logic start, reset, clk, color;
	logic [10:0] x, y;
	
	//Clock created
	parameter CLOCK_PERIOD=10;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	clearScreen dut (start, reset, clk, x, y, color);
	
	//checks to see that the variables are incrementing
	initial begin
		reset = 1; #10;
		reset = 0; #10;
		start = 1; #10000;
		$stop;
	end 
	
endmodule 