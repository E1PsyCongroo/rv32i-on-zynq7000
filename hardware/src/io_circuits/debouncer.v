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
    // One wrapping counter is required, one saturating counter is needed for each bit of glitchy_signal
    // You need to think of the conditions for reseting, clock enable, etc. those registers
    // Refer to the block diagram in the spec

    // Remove this line once you have created your debouncer
    wire [WRAPPING_CNT_WIDTH-1:0] sample_cnt_max;
    wire [SAT_CNT_WIDTH-1:0] pluse_cnt_max;
    assign sample_cnt_max = SAMPLE_CNT_MAX[WRAPPING_CNT_WIDTH-1:0];
    assign pluse_cnt_max = PULSE_CNT_MAX[SAT_CNT_WIDTH-1:0];

    reg [WRAPPING_CNT_WIDTH-1:0] wrapping_counter;
    reg [SAT_CNT_WIDTH-1:0] saturating_counter [WIDTH-1:0];

    integer j;
    initial begin
        wrapping_counter = 0;
        for (j = 0; j < WIDTH; j=j+1) begin
            saturating_counter[j] = 0;
        end
    end

    wire sample_pluse;

    always @(posedge clk) begin
        if (wrapping_counter == sample_cnt_max - 1) begin
            wrapping_counter <= 0;
        end
        else begin
            wrapping_counter <= wrapping_counter + 1;
        end
    end

    assign sample_pluse = (wrapping_counter == sample_cnt_max - 1) ? 1 : 0;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i=i+1) begin
            always @(posedge clk) begin
                if (sample_pluse && glitchy_signal[i]) begin
                    if (saturating_counter[i] < pluse_cnt_max) begin
                        saturating_counter[i] <= saturating_counter[i] + 1;
                    end
                    else begin
                        saturating_counter[i] <= saturating_counter[i];
                    end
                end
                else if(!glitchy_signal[i]) begin
                    saturating_counter[i] <= 0;
                end
                else begin
                    saturating_counter[i] <= saturating_counter[i];
                end
            end
            assign debounced_signal[i] = (saturating_counter[i] == pluse_cnt_max) ? 1 : 0;
        end
    endgenerate

endmodule
