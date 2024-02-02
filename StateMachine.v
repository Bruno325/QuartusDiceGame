module StateMachine(input wire clk, input wire power, dieRolled, resetBtn, hasWon, output reg [1:0] state);

	// State parameters
	parameter powerOff = 2'b00;
	parameter p1Turn = 2'b01;
	parameter p2Turn = 2'b10;
	parameter gameFinished = 2'b11;
	
	reg p1Rolled, p2Rolled;					// set to 0 if p1/p2 has rolled their die already, or 1 if p1/p2 has not rolled their die yet
	reg [1:0] currentState, nextState;	// keeps track of current and next state of our machine
	
	// set the current state of our machine
	always @ (posedge clk or negedge power) begin
	
		if (~power) begin
			currentState <= powerOff;
		end
		else begin
			currentState <= nextState;
		end
	
	end
	
	// set the output state of our machine
	always @ (posedge clk or negedge power) begin
	
		if (~power) begin
			state <= powerOff;	// puts board in power off state when SW[0] is off
		end
		else begin
			state <= currentState;
		end
	
	end
	
	// handle state transitions
	always @(*) begin

		nextState = currentState;
		
		case (currentState)
		
			// powering on borad will set the next state to player 1's turn
			powerOff: if (power) nextState = p1Turn;
			// rolling the die will take you to player 2's turn, pressing the reset button will reset the game, if we have won the game we go to gameFinished state
			p1Turn: if (~p1Rolled) nextState = p2Turn; else if (~resetBtn) nextState = powerOff; else if (hasWon) nextState = gameFinished;
			// rolling the die will take you to player 1's turn, pressing the reset button will reset the game, if we have won the game we go to gameFinished state 
			p2Turn: if (~p2Rolled) nextState = p1Turn; else if (~resetBtn) nextState = powerOff; else if (hasWon) nextState = gameFinished;
			// pressing the reset button will reset the game
			gameFinished: if (~resetBtn) nextState = powerOff;
			
			// Note: Turning the power switch, SW[0], off in any of these states will transition the state to powerOff immediately
		
		endcase
	
	end

	// let state machine know when either player has rolled their die
	always @(posedge clk or negedge dieRolled) begin
	
		case (currentState)
		
			p1Turn: begin
				if (~dieRolled) begin	// if button pressed during p1's turn
					p1Rolled = 0;			// p1 has rolled their die
					p2Rolled = 1;			// p2 has not rolled their die
				end
				else begin
					p1Rolled = 1;			// p1 has not rolled their die
					p2Rolled = 1;			// p2 has not rolled their die
				end
			end
			p2Turn: begin
				if (~dieRolled) begin	// if button pressed during p2's turn
					p2Rolled = 0;			// p2 has rolled their die
					p1Rolled = 1;			// p1 has not rolled their die
				end
				else begin
					p2Rolled = 1;			// p2 has not rolled their die
					p1Rolled = 1;			// p1 has not rolled their die
				end
			end
		endcase
		
	end
	

endmodule
