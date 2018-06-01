`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////////////
// 
// Nexys4_top.v - Top module of the system
// 
// Author: Thanh Tien Truong
//
// Description: 
// Create a connection between a reset pushbutton, a 7-segment LEDs controller
// and the interface with the HC_SR04.
//
///////////////////////////////////////////////////////////////////////////////////////////

module Nexys4_top(

    input           CLK,            // System clock - 100 Mhz clock
    input			btnCpuReset,	// CPU Reset button on Nexys4 DDR FPGA
    input           sw,
    output [15:0]   LED,

    // pulse signal connection
    input           pulse_signal,    // Connected to MISO pin on slave device
    
    output	[7:0]   an,             // Anodes on SSD
    output 	[6:0]	seg,            // Cathodes on SSD
    output          dp              // Cathode for decimal on SSD
);

// =================================================================================================
// 								Parameters, Register, and Wires
// =================================================================================================

    // Global wires
    wire	        sysclk;					  // 100MHz clock from on-board oscillator	
    wire	        sysreset;				  // system reset signal - asserted high to force reset
    wire 	        db_btn;				      // debounced button
    wire            db_sw;                    // debounced switches
    
    // 7-segment LED controlling signals
    wire [7:0]      segs_int;                 // sevensegment module the segments and the decimal point
    wire [4:0]		dig7, dig6, dig5, dig4,
                    dig3, dig2, dig1, dig0;   // display digits
    wire [7:0]      decpts;                   // decimal points

    wire [18:0]     time_high;
    wire [18:0]     time_low;
    wire [18:0]     binary_data_in;
        
    // For Binary to BCD converter
    wire [3:0]      hundred_thousands, ten_thousands, 
                    thousands, hundreds, tens, ones;
    
    reg clk_50Mhz = 1'b0;

// =================================================================================================
// 								Signal assigments
// ================================================================================================= 
    // global assigns
    assign sysreset     = ~db_btn;          // btnCpuReset is asserted low    
       
    // set up the display and LEDs
    assign    dig7   = {5'b11111};          // blank
    assign    dig6   = {5'b11111};
    assign    dig5   = {1'b0, hundred_thousands};
    assign    dig4   = {1'b0, ten_thousands};
        
    assign    dig3   = {1'b0, thousands};              
    assign	  dig2   = {1'b0, hundreds};            
    assign    dig1   = {1'b0, tens};          // raw value (tens)
    assign    dig0   = {1'b0, ones};          // raw value (ones)
    assign    decpts = 8'b00000000;          // Set decimal points on 7-segment LEDs  
       
    assign dp        = segs_int[7];
    assign seg       = segs_int[6:0];
   
// =================================================================================================
// 							  				Implementation
// =================================================================================================

    always @ (posedge CLK) begin
        clk_50Mhz <= ~clk_50Mhz;
    end

    //-------------------------------------------------------------------------
    //	 Generates debouncing signals for pushbutton and switches
    //-------------------------------------------------------------------------
	debounce #(
		.RESET_POLARITY_LOW(1)
	) DB(
		.clk      ( CLK         ),	       // Input  - 100 Mhz clock
		.pbtn_in  ( btnCpuReset ),         // Input  - Signal from pushbuttons
		.sw_in    ( sw          ),
		.pbtn_db  ( db_btn      ),         // Output - Debouncing signals for pushbuttons
		.sw_db    ( db_sw       )
	);	

    HC_SR04_interface HCSR04(
        .clk             ( clk_50Mhz     ),
        .reset           ( sysreset      ),
        .pulse_signal    ( pulse_signal  ),
        .clock_tick_high ( time_high ),
        .clock_tick_low  ( time_low  )
    );
    
    //-------------------------------------------------------------------------
    //     Converting a binary value to its BCD form
    //-------------------------------------------------------------------------
        
    assign binary_data_in = (sw == 1'b1) ? time_high : time_low;
        
    BCD_converter converter (
        .Binary     ( binary_data_in      ),       // Input  - 9-bit Binary data
        .Hundred_Thousands (hundred_thousands),
        .Ten_Thousands (ten_thousands),
        .Thousands  ( thousands           ),
        .Hundreds   ( hundreds            ),       // Output - 4-bit binary for hundreds
        .Tens       ( tens                ),       // Output - 4-bit binary for tens
        .Ones       ( ones                )        // Output - 4-bit binary for ones
    );

    //-------------------------------------------------------------------------
    //     Generating signals to control 7-segment LEDs on Nexys 4 DDR
    //-------------------------------------------------------------------------
    sevensegment #(
        .RESET_POLARITY_LOW(1)
    ) SSB (
        // inputs for control signals
        .d0(dig0),
        .d1(dig1),
        .d2(dig2),
        .d3(dig3),
        .d4(dig4),
        .d5(dig5),
        .d6(dig6),
        .d7(dig7),
        .dp(decpts),
                
        // outputs to seven segment display
        .seg(segs_int),            
        .an(an),
                
        // clock and reset signals (100 MHz clock, active high reset)
        .clk(CLK),
        .reset(sysreset)
    );
    
    assign LED = binary_data_in[15:0];
    
endmodule
