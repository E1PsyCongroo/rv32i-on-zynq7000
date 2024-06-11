module synchronizer #(
    parameter WIDTH = 1
) (
    input clk,
    input [WIDTH-1:0] async_signal,
    output [WIDTH-1:0] sync_signal
);
    // TODO: Create your 2 flip-flop synchronizer here
    // This module takes in a vector of WIDTH-bit asynchronous
    // (from different clock domain or not clocked, such as button press) signals
    // and should output a vector of WIDTH-bit synchronous signals
    // that are synchronized to the input clk

    reg [WIDTH-1:0] next_signal = 0, cur_signal = 0;
    always @(posedge clk) begin
        cur_signal <= next_signal;
        next_signal <= async_signal;
    end
    assign sync_signal = cur_signal;
endmodule
