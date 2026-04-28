// Switch map:
//   sw[0]     — mode:       0 = stopwatch, 1 = timer
//   sw[1]     — run/pause:  1 = run,       0 = pause
//   sw[2]     — load:       1 = load timer with sw[15:10]
//   sw[15:10] — load_value: 6-bit value to load into timer

module top (
    input        clk,           // 100 MHz on-board clock
    input        btnC,          // Centre button: resets both counters
    input  [15:0] sw,           // Switches (see map above)
    output [15:0] led,          // LEDs (see map above)
    output [3:0]  an,           // 7-segment anode outputs
    output [6:0]  seg           // 7-segment cathode outputs
);

    /******** DO NOT MODIFY ********/
    wire clk_1Hz;               // 1 Hz clock used by stopwatch and timer

    // In simulation there is no clock divider — run at 100 MHz so tests
    // don't have to wait real seconds. On the board, divide down to 1 Hz.
    `ifndef SYNTHESIS
        assign clk_1Hz = clk;
    `else
        clk_div #(.INPUT_FREQ(100_000_000), .OUTPUT_FREQ(1)) clk_div_1Hz
            (.iclk(clk), .rst(btnC), .oclk(clk_1Hz));
    `endif

    initial begin
        `ifndef SYNTHESIS
            $display("Stopwatch/Timer Frequency set to 100MHz");
        `else
            $display("Stopwatch/Timer Frequency set to 1Hz");
        `endif
    end

    // Seven-segment display — shows whichever counter is active (selected by mode)
    seven_segment_inf seven_segment_inf_inst (
        .clk  (clk),
        .rst  (btnC),
        .count(count),      // 6-bit value to display (stopwatch or timer)
        .anode(an),
        .segs (seg)
    );

    // Control signals decoded from switches
    wire        mode       = sw[0];      // 0 = stopwatch mode, 1 = timer mode
    wire        run        = sw[1];      // 1 = run, 0 = pause
    wire        load       = sw[2];      // 1 = load timer with load_value
    wire [5:0]  load_value = sw[15:10]; // 6-bit value to load into timer

    // Each module only runs when it is the active mode AND run = 1
    wire sw_en = (~mode) & run;         // stopwatch enable: mode=0 and run=1
    wire tm_en =   mode  & run;         // timer enable:     mode=1 and run=1

    // Stopwatch instance (up counter, 0 → 59 → 0)
    wire [5:0] stopwatch_state;

    stopwatch stopwatch_inst (
        .clk  (clk_1Hz),
        .rst  (btnC),
        .en   (sw_en),
        .state(stopwatch_state)
    );

   
    // Timer instance (down counter, load_value to 0, holds at 0)
    wire [5:0] timer_state;

    timer timer_inst (
        .clk       (clk_1Hz),
        .rst       (btnC),
        .en        (tm_en),
        .load      (load),
        .load_value(load_value),
        .state     (timer_state)
    );

    // Display mux: show stopwatch when mode=0, timer when mode=1
    wire [5:0] count = mode ? timer_state : stopwatch_state;

  
    // LED outputs
    assign led[8:3]   = stopwatch_state;    // stopwatch value on LEDs 3-8
    assign led[15:10] = timer_state;        // timer value on LEDs 10-15
    assign led[9]     = 1'b0;             
    assign led[2:0]   = 3'b0;            

endmodule
