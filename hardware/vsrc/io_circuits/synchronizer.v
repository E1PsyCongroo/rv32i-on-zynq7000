module synchronizer #(parameter WIDTH = 1) (
    input [WIDTH-1:0] async_signal,
    input clk,
    output [WIDTH-1:0] sync_signal
);
    // TODO: Create your 2 flip-flop synchronizer here
    // This module takes in a vector of WIDTH-bit asynchronous
    // (from different clock domain or not clocked, such as button press) signals
    // and should output a vector of WIDTH-bit synchronous signals
    // that are synchronized to the input clk

    wire [WIDTH-1:0] mid_signal;

    REGISTER # (
        .N      ( WIDTH         )
    ) u_reg1 (
        .q   	( mid_signal    ),
        .d   	( async_signal  ),
        .clk 	( clk           )
    );

    REGISTER # (
        .N      ( WIDTH         )
    ) u_reg2 (
        .q   	( sync_signal   ),
        .d   	( mid_signal    ),
        .clk 	( clk           )
    );

endmodule
