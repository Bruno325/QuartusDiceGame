# QuartusDiceGame - Anthony Bruno
This is a 2-player dice game meant to be played on a DE10-Lite Board. 
The code was written in the Intel Quartus Design Software using Verilog.
Each player will roll a die and the first to roll a number higher than their opponent five times will win the game.

How To Play:

1. Flip the rightmost switch to start/"power on" the game, displaying the score. 1 LED will be turned on to indicate Player 1's turn.
2. Press the button labeled KEY0 on the board to roll Player 1's die. The outcome will be displayed on the rightmost hex display. 2 LEDs will be on to indicate it is not Player 2's turn.
3. Press the KEY0 button again to roll Player 2's die. The score will update on the hex displays. If a player has achieved 5 points, the game will end and turn all LEDs on. If no player has reached 5 points yet, it will return to Player 1's turn.

Note: At any point in the game, you may press the button labeled KEY1 on the board to reset the game. This will clear all previous rolls and revert the score back to 0-0.
