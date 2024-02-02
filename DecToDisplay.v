module DecToDisplay(input [7:0] num, output reg [7:0] display);

	always @(*) begin
	
		case (num)
			
			// if num is 0-6, display the number on HEX display
			8'd0: display = 8'b11000000; 
			8'd1: display = 8'b11111001;
			8'd2: display = 8'b10100100;
			8'd3: display = 8'b10110000;
			8'd4: display = 8'b10011001;
			8'd5: display = 8'b10010010;
			8'd6: display = 8'b10000010;	
			
			// if num is 99, clear the display
			8'd99: display = 8'b11111111;
			
			// display hyphen
			8'b10111111: display = 8'b10111111;
			
		endcase
	
	end

endmodule
