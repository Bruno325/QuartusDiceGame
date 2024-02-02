`define ENABLE_ADC_CLOCK
`define ENABLE_CLOCK1
`define ENABLE_CLOCK2
`define ENABLE_SDRAM
`define ENABLE_HEX0
`define ENABLE_HEX1
`define ENABLE_HEX2
`define ENABLE_HEX3
`define ENABLE_HEX4
`define ENABLE_HEX5
`define ENABLE_KEY
`define ENABLE_LED
`define ENABLE_SW
`define ENABLE_VGA
`define ENABLE_ACCELEROMETER
`define ENABLE_ARDUINO
`define ENABLE_GPIO

module DE10_LITE_Golden_Top(

	//////////// ADC CLOCK: 3.3-V LVTTL //////////
`ifdef ENABLE_ADC_CLOCK
	input 		          		ADC_CLK_10,
`endif
	//////////// CLOCK 1: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK1
	input 		          		MAX10_CLK1_50,
`endif
	//////////// CLOCK 2: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK2
	input 		          		MAX10_CLK2_50,
`endif

	//////////// SDRAM: 3.3-V LVTTL //////////
`ifdef ENABLE_SDRAM
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,
`endif

	//////////// SEG7: 3.3-V LVTTL //////////
`ifdef ENABLE_HEX0
	output		     [7:0]		HEX0,
`endif
`ifdef ENABLE_HEX1
	output		     [7:0]		HEX1,
`endif
`ifdef ENABLE_HEX2
	output		     [7:0]		HEX2,
`endif
`ifdef ENABLE_HEX3
	output		     [7:0]		HEX3,
`endif
`ifdef ENABLE_HEX4
	output		     [7:0]		HEX4,
`endif
`ifdef ENABLE_HEX5
	output		     [7:0]		HEX5,
`endif

	//////////// KEY: 3.3 V SCHMITT TRIGGER //////////
`ifdef ENABLE_KEY
	input 		     [1:0]		KEY,
`endif

	//////////// LED: 3.3-V LVTTL //////////
`ifdef ENABLE_LED
	output		     [9:0]		LEDR,
`endif

	//////////// SW: 3.3-V LVTTL //////////
`ifdef ENABLE_SW
	input 		     [9:0]		SW,
`endif

	//////////// VGA: 3.3-V LVTTL //////////
`ifdef ENABLE_VGA
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		          		VGA_HS,
	output		     [3:0]		VGA_R,
	output		          		VGA_VS,
`endif

	//////////// Accelerometer: 3.3-V LVTTL //////////
`ifdef ENABLE_ACCELEROMETER
	output		          		GSENSOR_CS_N,
	input 		     [2:1]		GSENSOR_INT,
	output		          		GSENSOR_SCLK,
	inout 		          		GSENSOR_SDI,
	inout 		          		GSENSOR_SDO,
`endif

	//////////// Arduino: 3.3-V LVTTL //////////
`ifdef ENABLE_ARDUINO
	inout 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N,
`endif

	//////////// GPIO, GPIO connect to GPIO Default: 3.3-V LVTTL //////////
`ifdef ENABLE_GPIO
	inout 		    [35:0]		GPIO
`endif
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

reg [2:0] p1Roll, p2Roll;						// hold player 1 and 2's die values
reg [7:0] rollToDisp;							//	the value for HEX0 to display (set to p1Roll or p2Roll depending on who's turn it is
reg [3:0] p1Score, p2Score;					// hold player 1 and 2's scores
reg [7:0] scoreDisplay1, scoreDisplay2;	// values for HEX5 and HEX3 to display
reg [7:0] scoreHyphen;							// holds value to display a hyphen on HEX4 - just for score display formatting
reg [9:0] ledVal;									// holds value for LEDs to display - can indicate player 1/player 2's turn or if the game was won
reg hasWon;											// set to 0 if no one has won, set to 1 if someone has won by reaching 5 points
reg canRoll;										// set to 0 if we should not be able to roll the die - when the game is off or won - and set to 1 if we are able to roll the die - it is someone's turn

wire [2:0] whichRoll;							// holds the randomly generated number to be assigned to p1Roll or p2Roll depending on who's turn it is
wire cout, fastClk;								// cout is clock used for random number generation and fastClk is how fast the score and rolls update
wire [31:0] count;								// holds value based on cout that will be used for random number generation
wire [1:0] state;									// holds the binary state of our game: 00 - powered off, 01 - p1 turn, 10 - p2 turn, 11 - game won

//=======================================================
//  Structural coding
//=======================================================

// Turn off HEX2 and HEX3, they will not be used
assign HEX2 = 8'b11111111;
assign HEX1 = 8'b11111111;

// Slow board's clocks to be useable for the game
ClockDivider(MAX10_CLK1_50, cout, count);
ClockDividerFast(MAX10_CLK2_50, fastClk);

// Assign HEX displays and LEDs
DecToDisplay(rollToDisp, HEX0);
DecToDisplay(scoreDisplay1, HEX5);
DecToDisplay(scoreHyphen, HEX4);
DecToDisplay(scoreDisplay2, HEX3);
assign LEDR = ledVal;

// Roll random number once KEY[0] button is pressed, stored in whichRoll
RollNum(KEY[0], whichRoll, count, canRoll);

// Run the state machine
StateMachine(fastClk, SW[0], KEY[0], KEY[1], hasWon, state);

// Update every negedge of the clock
always @(negedge fastClk) begin

	case (state)
	
		// If game is off, clear all display, LED, score and roll values (Note: value of 99 means off - see DecToDisplay.v)
		2'b00: begin
			rollToDisp = 99;
			p1Score = 0;
			p2Score = 0;
			scoreHyphen = 99;
			scoreDisplay1 = 99;
			scoreDisplay2 = 99;
			p2Roll = 99;
			p1Roll = 99;
			ledVal = 10'b0000000000;
			hasWon = 0;
			canRoll = 0;
		end
		
		// If p1's turn
		2'b01: begin
		
			// turn on 1 LED to indicate p1's turn
			ledVal = 10'b1000000000;
			
			// display score
			scoreDisplay1 = p1Score;
			scoreDisplay2 = p2Score;
			scoreHyphen = 8'b10111111;
			
			//allow us to roll the die
			canRoll = 1;
			
			// set p1Roll to randomly generated number once KEY[0] button is pressed and display it on HEX0
			if(~KEY[0]) begin
				p1Roll = whichRoll;
				rollToDisp = p1Roll;
			end
			
			// Check if game has been won
			if (p1Score > 4 || p2Score > 4) begin
					hasWon = 1;
			end
			
		end
		
		// If p2's turn
		2'b10: begin
		
			// turn on 2 LEDs to indicate p2's turn
			ledVal = 10'b1100000000;
			
			// display score
			scoreDisplay1 = p1Score;
			scoreDisplay2 = p2Score;
			scoreHyphen = 8'b10111111;
			
			// set p2Roll to randomly generated number once KEY[0] button is pressed and display it on HEX0
			if (~KEY[0]) begin
				p2Roll = whichRoll;
				rollToDisp = p2Roll;
				
				// check who rolled higher value and update score
				if (p1Roll > p2Roll) begin
					p1Score = p1Score + 1;
				end
				else if (p1Roll < p2Roll) begin
					p2Score = p2Score + 1;
				end
				else begin // both players get points for a tie
					p1Score = p1Score + 1;
					p2Score = p2Score + 1;
				end
				
			end
			
			// Check if game has been won
			if (p1Score > 4 || p2Score > 4) begin
					hasWon = 1;
			end
			
		end
		
		// If game has been won, clear roll display, disable die rolls, turn all LEDs on, and the score will still be showing
		2'b11: begin
			rollToDisp = 99;
			canRoll = 0;
			ledVal = 10'b1111111111;
		end
		
	endcase

end


endmodule
