module LFSR_10Bit( clk, reset, Q );
	input  logic clk;
	input  logic reset;

	localparam NumOfBit = 10;
	output logic [ NumOfBit : 1 ] Q;
	logic D;

	xnor( D, Q[ 7 ], Q[ 10 ]); 

	always_ff @( posedge clk ) begin
		if ( reset ) begin
			Q <= '0;
		end else begin
			Q <= { Q[ NumOfBit - 1 : 1 ], D };
		end
	end

endmodule 
	
module LFSR_10Bit_testbench();   
	logic  clk, reset;

	localparam NumOfBit = 10;
	logic [ NumOfBit : 1 ] Q;

	LFSR_10Bit dut( .clk, .reset, .Q );      
  
	parameter CLOCK_PERIOD = 100;   
	initial begin 
		clk <= '0;  
		forever #( CLOCK_PERIOD / 2 ) clk <= ~clk;   
	end      
 
	initial begin                        
						@(posedge clk);    
		reset <= 1; @(posedge clk);    
		reset <= 0; @(posedge clk);                        
						@(posedge clk);                        
						@(posedge clk);                        
						@(posedge clk);                
		while (Q != 10'b0) begin
			@(posedge clk);  
		end				
		$stop;   
	end  
endmodule 