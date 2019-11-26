// Code from "FPGA prototyping by SystemVerilog examples" by P. Chu

module reg_file
   #(
    parameter DATA_WIDTH = 8, // number of bits
              ADDR_WIDTH = 2  // number of address bits
   )
   (
    input  logic clk,
	 input logic reset,
    input  logic wr_en,
    input  logic [ADDR_WIDTH-1:0] w_addr, r_addr,
    input  logic [DATA_WIDTH-1:0] w_data,
    output logic [DATA_WIDTH-1:0] r_data
   );

   // signal declaration
   logic [DATA_WIDTH-1:0] array_reg [0:2**ADDR_WIDTH-1];

   // body
   // write operation
   always_ff @(posedge clk) begin
		if (reset) begin
			// initialize the FIFO to all 0's so it doesn't output X's before its full
			for (int i = 0; i < 2**ADDR_WIDTH; i++)
				array_reg[i] <= '0;
		end
		else if (wr_en)
         array_reg[w_addr] <= w_data;
			
	end
   // read operation
   assign r_data = array_reg[r_addr];
endmodule

module reg_file_testbench #(parameter DATA_WIDTH = 8, ADDR_WIDTH = 2) ();	
	logic clk;
	logic reset;
	logic wr_en;
   logic [ADDR_WIDTH-1:0] w_addr, r_addr;
   logic [DATA_WIDTH-1:0] w_data;
   logic [DATA_WIDTH-1:0] r_data;
	
	reg_file dut (.*);
	
	parameter CLOCK_PERIOD = 10;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1; #10;
		reset <= 0; #10;
		w_addr <= 0; w_data <= '1; wr_en <= 1; #10;
		repeat(4) #10;
		r_addr <= 0; #10;
		$stop;
	end
	
	
endmodule
