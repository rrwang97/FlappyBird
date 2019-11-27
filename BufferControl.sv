module BufferControl #(parameter N = 11) (clock, reset, pipex0, pipey0, pipex1, pipey1, birdx0, birdy0, birdx1, birdy1,
														x0, y0, x1, y1, wr, clearScreen);

	input logic clock, reset;
	input logic [N-1:0] pipex0, pipey0, pipex1, pipey1, birdx0, birdy0, birdx1, birdy1; //initial and end coordinates
	logic [N-1:0] nx0, ny0, nx1, ny1;
	integer i=0; 
	logic porb;
	output logic [N-1:0] x0, y0, x1, y1;
	output logic clearScreen, wr; //porb will help the memory module place the coordinates
								//in the right spot
	
	//Logic for choosing to push bird or pipe values to buffer
	always_comb begin
		if (reset) begin
			porb = 0;
		end
		else if (i == 0) porb = 0;
		else porb = 1; 
	end
	
	//Logic for choosing to push bird or pipe values to buffer
	//1 for pipe and 0 for bird
	always_comb begin
		case(porb)
			1: begin
				nx0 = pipex0;
				ny0 = pipey0;
				nx1 = pipex1;
				ny1 = pipey1;
			end
			0: begin
				nx0 = birdx0;
				ny0 = birdy0;
				nx1 = birdx1;
				ny1 = birdy1;
			end
		endcase 
	end
	
	always_ff @(posedge clock) begin
		if (reset) begin //Fix reset to restart game
			i <= 0;
			x0 <= 0;
			y0 <= 0;
			x1 <= 0;
			y1 <= 0;
			wr <= 1;
		end
		else begin
			x0 <= nx0;
			y0 <= ny0;
			x1 <= nx1;
			y1 <= ny1;
			wr <= 1;
		end
		
		if (i == 7) begin
			i <= 0;
			clearScreen <= 1;
		end
		else begin
			i <= i + 1;
			clearScreen <= 0;
		end
	end

endmodule 

module BufferControl_testbench();
	logic clk, reset, porb;
	logic [9:0] x0, y0, x1, y1, pipex0, pipey0, pipex1, pipey1, birdx0, birdy0, birdx1, birdy1;
	
	//Sets clock period
	parameter CLOCK_PERIOD=10;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	BufferControl dut (clk, reset, pipex0, pipey0, pipex1, pipey1, birdx0, birdy0, birdx1, birdy1, porb,
							 x0, y0, x1, y1);
							 
	initial begin
		reset=0; #10;
		reset=1; #10;
		reset=0; 
		pipex0 = 1;
		pipey0 = 1;
		pipex1 = 1;
		pipey1 = 1;
		birdx0 = 5;
		birdy0 = 5;
		birdx1 = 5;
		birdy1 = 5; #100;
	end


endmodule 