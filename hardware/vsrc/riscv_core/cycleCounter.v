module cycleCounter (
  input clk,
  input rst,
  output [31:0] cycleCount
);
  wire [31:0] cycle_next;
  assign cycle_next = cycleCount + 1;

  REGISTER_R # (
    .N    ( 32          )
  ) u_cycleCounter (
    .q   	( cycleCount  ),
    .d   	( cycle_next  ),
    .rst 	( rst         ),
    .clk 	( clk         )
  );

endmodule