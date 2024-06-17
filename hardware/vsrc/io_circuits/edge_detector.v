module edge_detector #(
    parameter WIDTH = 1
)(
    input clk,
    input [WIDTH-1:0] signal_in,
    output [WIDTH-1:0] edge_detect_pulse
);
    // TODO: implement a multi-bit edge detector that detects a rising edge of 'signal_in[x]'
    // and outputs a one-cycle pulse 'edge_detect_pulse[x]' at the next clock edge
    // Feel free to use as many number of registers you like

    wire [WIDTH-1:0] old_signal;

    REGISTER # (
        .N      ( WIDTH         )
    ) u_reg1 (
        .q   	( old_signal    ),
        .d   	( signal_in     ),
        .clk 	( clk           )
    );

    assign edge_detect_pulse = ~old_signal & signal_in;

endmodule
