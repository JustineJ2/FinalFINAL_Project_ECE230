// Timer: counts down from load_value to 0, then holds at 0
module timer(
    input clk,
    input rst,
    input en,
    input load,
    input [5:0] load_value,     // value to load into counter
    output reg [5:0] state      // 6-bit register (D flip-flops)
);
    // This always block represents sequential logic (flip-flops)
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= 6'd0;              // reset to 0
        else if (load)
            state <= load_value;        // synchronous load: set counter to load_value
        else if (en) begin
            if (state == 6'd0)
                state <= 6'd0;          // hold at 0 (no wrap-around)
            else
                state <= state - 6'd1;  // down counter
        end
        else
            state <= state;             // hold value (no change)
    end
endmodule
