// Stopwatch: Modulo-60 behavior (counts 0 to 59 to 0)
module stopwatch(
    input clk,
    input rst,
    input en,
    output reg [5:0] state      // 6-bit register to represent highest number (59)
);
    // Always block represents sequential logic (flip-flops) 
    //Async reset to 0, en the counter; wraps 59 to 0
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= 6'd0;          // reset to 0
        else if (en) begin
            if (state == 6'd59)
                state <= 6'd0;      // wrap back to 0 after 59
            else
                state <= state + 6'd1; // up counter
        end
        else
            state <= state;         // hold value (no change)
    end
endmodule
