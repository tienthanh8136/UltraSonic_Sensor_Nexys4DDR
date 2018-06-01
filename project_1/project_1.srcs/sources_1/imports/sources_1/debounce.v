`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// debounce.v - debounces pushbuttons and switches
//
// Description:
// ------------
// This circuit filters out mechanical bounce. It works by taking
// several time samples of the pushbutton and changing its output
// only after several sequential samples are the same value
// 
///////////////////////////////////////////////////////////////////////////

module debounce
#(
	// parameters
	parameter integer	CLK_FREQUENCY_HZ		= 100000000, 
	parameter integer	DEBOUNCE_FREQUENCY_HZ	= 250,
	parameter integer	RESET_POLARITY_LOW		= 1,
	parameter integer 	CNTR_WIDTH 				= 32
)
(
	// ports
	input				clk,				// clock	
	input 		        pbtn_in,			// pushbutton inputs - including CPU RESET button
    input               sw_in,
    output reg          sw_db = 1'b0,
	output reg	     	pbtn_db  = 1'b0 	// debounced outputs of pushbuttons	
);

	// Need to take CPU reset's polarity into account
	localparam [3:0]	pb_in = RESET_POLARITY_LOW ? 4'h1 : 4'h0;
	
	// debounce clock divider 
	reg			[CNTR_WIDTH-1:0]	db_count = 0;
	wire		[CNTR_WIDTH-1:0]	top_cnt = ((CLK_FREQUENCY_HZ / DEBOUNCE_FREQUENCY_HZ) - 1);


	//shift registers used to debounce switches and buttons	
	reg [3:0]  shift_pb = pb_in;	
	reg [3:0]  shift_sw = 4'h0;
	
	// debounce clock
	always @(posedge clk)
	begin 
		if (db_count == top_cnt)
			db_count <= 1'b0;	
		else
			db_count <= db_count + 1'b1;
	end	// debounce clock
	
	always @(posedge clk) 
	begin
		if (db_count == top_cnt) begin	
			//shift registers for pushbuttons
			shift_pb	<= (shift_pb << 1) | pbtn_in;
			shift_sw    <= (shift_sw << 1) | sw_in;		
		end
		
		//debounced pushbutton outputs
		case(shift_pb) 4'b0000: pbtn_db <= 0; 4'b1111: pbtn_db <= 1; endcase
		case(shift_sw) 4'b0000: sw_db <= 0; 4'b1111: sw_db <= 1; endcase
	end
	
endmodule
