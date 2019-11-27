module FrameBufferFeed #(parameter N=11)(clock, reset, empty, inx0, iny0, inx1, iny1, x0, y0, x1, y1, rd);
	input logic clock, reset, empty; //empty signal comes from memory module
	input logic [N-1:0] inx0, iny0, inx1, iny1;
	output logic rd;
	output logic [N-1:0] x0, y0, x1, y1;
	
	always_ff @(posedge clock) begin
		if (reset) begin
			x0 <= 0;
			y0 <= 0;
			x1 <= 0;
			y1 <= 0;
			rd <= 0;
		end
		else if (!empty) begin
			rd <= 1;
			x0 <= inx0;
			y0 <= iny0;
			x1 <= inx1;
			y1 <= iny1;
		end
	end
endmodule 