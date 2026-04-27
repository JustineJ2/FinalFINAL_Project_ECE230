// Stopwatch: Modulo-60 behavior (counts 0 to 59 to 0)
module stopwatch(
    input clk,
    input rst,
    input en,
    output reg [5:0] state      // 6-bit register (D flip-flops)
);
    // This always block represents sequential logic (flip-flops)
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
