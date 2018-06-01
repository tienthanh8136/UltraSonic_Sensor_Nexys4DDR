// Distance (cm) 	= (counter_echo/50_000_000) * (34000/2)
//      x cm     	=  counter_echo * (34000/100_000_000)
//   
// ==> counter_echo =  (x * 100_000_000 / 34000) = (x * 100_000 / 34)
//           
//        x (cm)    | 	    counter_echo
//         1        |       2941 * 1 = 2941
//         2        |       2941 * 2 = 5882
//         3        |       2941 * 3 = 8823
//         4        |       2941 * 4 = 11764
//        10        |       2941 * 10 = 29410
//        20        |       2941 * 20 = 58820
//        30        |       2941 * 30 = 88230
//        40        |       2941 * 40 = 117640
//        50        |       2941 * 50 = 147050

module HC_SR04_interface(
	 input             clk,
	 input             reset,
	 input             pulse_signal,
	 output  [18:0]    clock_tick_high,
	 output  [18:0]    clock_tick_low
);

//=========================================================================================
//                      Parameters, wires and registers declaration
//=========================================================================================
	reg [18:0] counter_pulse_high  = 19'b0;     
	reg [18:0] counter_pulse_low   = 19'b0;     
	
	reg [18:0] int_high_time       = 19'b0;
	reg [18:0] int_low_time        = 19'b0;
	
    // registers to synchronize echo signal
	reg      	pulse_signal_last;
    reg         pulse_signal_synced;
    reg         pulse_signal_unsynced;

//=========================================================================================
//                      Implementation
//=========================================================================================

    always @(posedge clk or posedge reset) begin
	    if (reset) begin	
            pulse_signal_last           <= 1'b0;
            pulse_signal_synced         <= 1'b0;
            pulse_signal_unsynced       <= 1'b0;
            counter_pulse_high  <= 19'b0;
            counter_pulse_low   <= 19'b0;
            int_high_time       <= 19'b0;
            int_low_time        <= 19'b0;
        end
        else begin
        
		    //-------------------------------------------------------------------------------
		    // Calculate the clock tick for high and low peiod of the signal
		    //-------------------------------------------------------------------------------
		    // If a rising edge of pulse_signal is detected
            if (pulse_signal_last == 1'b0 && pulse_signal_synced == 1'b1) begin
                int_low_time        <= counter_pulse_low;
                counter_pulse_high  <= 19'b0;
            end
            // If a falling edge of echo is detected
            else if (pulse_signal_last == 1'b1 && pulse_signal_synced == 1'b0) begin
                int_high_time       <= counter_pulse_high;
                counter_pulse_low   <= 19'b0;
            end
            // While echo is high
            else if (pulse_signal_last == 1'b1 && pulse_signal_synced == 1'b1) begin
                counter_pulse_high <= counter_pulse_high + 1'b1;
            end       
            // While echo is low 
            else begin
                counter_pulse_low <= counter_pulse_low + 1'b1;
            end
        end
        
        // Synchronize echo signal (3 FFs)
        pulse_signal_last 		<= pulse_signal_synced;
        pulse_signal_synced     <= pulse_signal_unsynced;
        pulse_signal_unsynced   <= pulse_signal;        				
    end
 
    // Assign values to outputs
    assign clock_tick_high  = int_high_time;
    assign clock_tick_low   = int_low_time;
 
endmodule