module RollNum(input wire btn, output reg [2:0] num, input [31:0] count, input canRoll);

	// Generate Random Number on posedge of Button
	always @(posedge btn) begin
	
		if (canRoll == 1) begin
			num = count % 6 + 1;
		end
	
	end


endmodule
