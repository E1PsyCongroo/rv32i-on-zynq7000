module debouncer #(
    parameter WIDTH              = 1,
    parameter SAMPLE_CNT_MAX     = 62500,
    parameter PULSE_CNT_MAX      = 200,
    parameter WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX),
    parameter SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1
) (
    input clk,
    input [WIDTH-1:0] glitchy_signal,
    output [WIDTH-1:0] debounced_signal
);
    // TODO: fill in neccesary logic to implement the wrapping counter and the saturating counters
    // Some initial code has been provided to you, but feel free to change it however you like
    // One wrapping counter is required
    // One saturating counter is needed for each bit of glitchy_signal
    // You need to think of the conditions for reseting, clock enable, etc. those registers
    // Refer to the block diagram in the spec

    wire [WRAPPING_CNT_WIDTH-1:0] wrapping_count, wrapping_count_next;
    wire sample_pluse;

    REGISTER_R # (
        .N      ( WRAPPING_CNT_WIDTH    )
    ) wrapping_counter (
        .q   	( wrapping_count        ),
        .d   	( wrapping_count_next   ),
        .rst    ( sample_pluse          ),
        .clk 	( clk                   )
    );

    assign sample_pluse = (wrapping_count == SAMPLE_CNT_MAX - 1) ? 1 : 0;
    assign wrapping_count_next = wrapping_count + 1;

    wire [SAT_CNT_WIDTH-1:0] saturating_counter [WIDTH-1:0];
    wire [SAT_CNT_WIDTH-1:0] saturating_counter_next [WIDTH-1:0];
    wire [WIDTH-1:0] saturating_counter_max ;
    wire [WIDTH-1:0] saturating_counter_next_ce;
    wire [WIDTH-1:0] saturating_counter_rst;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin
            assign saturating_counter_next[i] = saturating_counter[i] + 1;
            assign saturating_counter_max[i] = saturating_counter[i] == PULSE_CNT_MAX;
            assign saturating_counter_rst[i] = ~glitchy_signal[i];
            assign saturating_counter_next_ce[i] = ~saturating_counter_max[i] & sample_pluse & glitchy_signal[i];
            REGISTER_R_CE # (
                .N      ( SAT_CNT_WIDTH                 )
            ) saturating_counterer (
                .q      ( saturating_counter[i]         ),
                .d      ( saturating_counter_next[i]    ),
                .rst    ( saturating_counter_rst[i]     ),
                .ce     ( saturating_counter_next_ce[i] ),
                .clk    ( clk                           )
            );
        end
    endgenerate

    assign debounced_signal = saturating_counter_max;

endmodule
