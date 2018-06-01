`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// BCD_converter module
// --------------------
// Input:
// - 9-bit binary
// Output:
// - 4-bit hundreds
// - 4-bit tens
// - 4-bit ones
// 
// Method - Shift and add 3:
// .........................
// Example: Convert 1111 (binary) --> 15 (BCD):
//
// Operations |     tens      |        ones          |       binary       |
//    N/A     |               |                      |        1111        |
//   shift    |               |           1          |        111         |
//   shift    |               |          11          |        11          |
//   shift    |               |         111          |        1           |
//   add 3    |               |        +011          |        1           |
//    N/A     |               |        1010          |        1           |
//   shift    |        1      |        0101          |                    |     <--- STOP
//                     |                 |
//                     V                 V
//   Result            1                 5
//
// Notice (for bigger number):
// ---------------------------
// Before doing the next shift operation, we have to check values in thousand, hundreds, tens or ones 
// If any of them is greater or equal 5, add 3 to it.
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

module BCD_converter (
    input       [18:0] Binary,		// Hold value to convert
    output reg  [3:0] Hundred_Thousands,
    output reg  [3:0] Ten_Thousands,
    output reg  [3:0] Thousands,
    output reg  [3:0] Hundreds,		// Hold value of hundreds - BCD
    output reg  [3:0] Tens,		    // Hold value of tens - BCD
    output reg  [3:0] Ones		    // Hold value of ones - BCD
);

reg not_ready = 1'b0;
integer i;				        // variable for shifting all the bit of the binary

always @(Binary)
begin
    Hundred_Thousands = 4'b0000;
    Ten_Thousands = 4'b0000;
    Thousands = 4'b0000;
	Hundreds = 4'b0000;         // default value for hundreds
	Tens = 4'b0000;             // default value for tens
	Ones = 4'b0000;             // default value for ones
    
    //if (not_ready == 1'b1) begin
        for (i = 18; i >= 0; i = i-1) begin
        
            //not_ready = 1'b0;
        
            // add 3 if greater than or equal 5 
            if (Hundred_Thousands >= 5)
                Hundred_Thousands = Hundred_Thousands + 3;
            if (Ten_Thousands >= 5)
                Ten_Thousands = Ten_Thousands + 3;                   
		    if (Thousands >= 5)
                Thousands = Thousands + 3;
		    if (Hundreds >= 5)
			    Hundreds = Hundreds + 3;
		    if (Tens >= 5)
			    Tens = Tens + 3;
		    if (Ones >= 5)
			    Ones = Ones + 3;
		
		    // shift 1 bit to the left
		    Hundred_Thousands = Hundred_Thousands << 1;
            Hundred_Thousands[0] = Ten_Thousands[3];
                
            Ten_Thousands = Ten_Thousands << 1;
            Ten_Thousands[0] = Thousands[3];
                        
		    Thousands = Thousands << 1;
		    Thousands[0] = Hundreds[3];
		
		    Hundreds = Hundreds << 1;
		    Hundreds[0] = Tens[3];

		    Tens = Tens << 1;
		    Tens[0] = Ones[3];

		    Ones = Ones << 1;
		    Ones[0] = Binary[i];
	   end
	   //not_ready = 1'b1;
    //end
end

endmodule