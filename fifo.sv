// Listing 7.8
module fifo
   #(
    parameter DATA_WIDTH=8, // number of bits in a word
              ADDR_WIDTH=4  // number of address bits
   )
   (
    input  logic clk, reset,
    input  logic rd, wr,
    input  logic [DATA_WIDTH-1:0] w_data,
    output logic empty, full,
    output logic [DATA_WIDTH-1:0] r_data
   );

   //signal declaration
   logic [ADDR_WIDTH-1:0] w_addr, r_addr;
   logic wr_en, full_tmp;

   // body
   // write enabled only when FIFO is not full
   assign wr_en = wr & ~full_tmp; 
   assign full = full_tmp;
   
   // instantiate fifo control unit
   fifo_ctrl #(.ADDR_WIDTH(ADDR_WIDTH)) c_unit
      (.*, .full(full_tmp));

   // instantiate register file
   reg_file 
      #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) f_unit (.*);
endmodule

module fifo_testbench #(parameter DATA_WIDTH=8, ADDR_WIDTH=4) ();
	logic clk, reset, rd, wr;
	logic [DATA_WIDTH-1:0] w_data;
	logic empty, full;
	logic [DATA_WIDTH-1:0] r_data;
	
	fifo dut (.*);
	parameter CLOCK_PERIOD = 10;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1; #10;
		reset <= 0; #10;
		 w_data <= '1; wr <= 1; #10;
		repeat(2**ADDR_WIDTH) #10; // fill FIFO
		w_data <= '0; #10;
		repeat(5);
		
		rd <= 1; wr <= 0; #10;
		repeat(20) #10;
		$stop;
	end
	
endmodule
