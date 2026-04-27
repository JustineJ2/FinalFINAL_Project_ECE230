module seven_segment_inf (
    input clk,              // 100 MHz clock
    input rst,
    input [5:0] count,     // 0-59 seconds
    output [3:0] anode,
    output reg [6:0] segs
);

// 1. Generate Scan Clock (~1 kHz)
reg [15:0] scan_cnt = 0;
wire scan_clk;

always @(posedge clk) begin
    if (rst)
        scan_cnt <= 0;
    else
        scan_cnt <= scan_cnt + 1;
end

assign scan_clk = scan_cnt[15];  // ~1 kHz


// 2. Split into tens/ones
wire [3:0] tens;
wire [3:0] ones;

assign tens = count / 10;
assign ones = count % 10;


// 3. Scanner (digit select)
reg [1:0] an_cnt;

always @(posedge scan_clk) begin
    if (rst)
        an_cnt <= 0;
    else
        an_cnt <= an_cnt + 1;
end

assign anode = ~(1 << an_cnt);   // active-low


// 4. Select digit to display
reg [3:0] selected;

always @(*) begin
    case(anode)
        4'b1110: selected = ones;   // rightmost
        4'b1101: selected = tens;
        4'b1011: selected = 4'd15;  // blank
        4'b0111: selected = 4'd15;  // blank
        default: selected = 4'd15;
    endcase
end


// 5. 7-Segment Decoder
// GFEDCBA (active-low)
always @(*) begin
    case(selected)
        0: segs = 7'b1000000;
        1: segs = 7'b1111001;
        2: segs = 7'b0100100;
        3: segs = 7'b0110000;
        4: segs = 7'b0011001;
        5: segs = 7'b0010010;
        6: segs = 7'b0000010;
        7: segs = 7'b1111000;
        8: segs = 7'b0000000;
        9: segs = 7'b0010000;
        default: segs = 7'b1111111; // blank
    endcase
end

endmodule