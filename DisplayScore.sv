// Hex display module to display hex 0-F on two 7-seg hex displays
module DisplayScore (score, HEX0, HEX1);
	input logic [6:0] score;
	output logic [6:0] HEX0, HEX1; 
	
	logic [6:0] blank, zero, one, two, three, four, five, six, seven, eight, nine;
	
	assign blank = 7'b1111111;
	assign zero = 7'b1000000;
	assign one = 7'b1111001;
	assign two = 7'b0100100;
	assign three = 7'b0110000;
	assign four = 7'b0011001;
	assign five = 7'b0010010;
	assign six = 7'b0000010;
	assign seven = 7'b1111000;
	assign eight =  7'b0000000; // also all lights on
	assign nine = 7'b0011000;
	
	// combinational logic that uses the score input to update the display
	// with the correct message and/or number
	
	// 1's place
	always_comb begin
		case(score % 10)
			0:	HEX0 = zero;
			1:	HEX0 = one;
			2:	HEX0 = two;
			3:	HEX0 = three;
			4:	HEX0 = four;
			5:	HEX0 = five;
			6:	HEX0 = six;
			7:	HEX0 = seven;
			8:	HEX0 = eight;
			9:	HEX0 = nine;			
			default:	HEX0 = blank;
		endcase
	end
	
	// 10's place
	always_comb begin
		case( score / 10 % 100)
			0:	HEX1 = zero;
			1:	HEX1 = one;
			2:	HEX1 = two;
			3:	HEX1 = three;
			4:	HEX1 = four;
			5:	HEX1 = five;
			6:	HEX1 = six;
			7:	HEX1 = seven;
			8:	HEX1 = eight;
			9:	HEX1 = nine;			
			default:	HEX1 = blank;
		endcase
	end
	
endmodule

module DisplayScore_testbench();
	logic [6:0] score;
	logic [6:0] HEX0, HEX1;
	
	DisplayScore dut (.*);
	
	int i;
	
	initial begin
		for (i = 0; i <= 101; i++) begin
			score <= i; #10;
		end
		$stop;
	end
	
endmodule
	