module timer # (
  parameter CPU_CLOCK_FREQ = 50_000_000
) (
  input clk,
  input rst,
  output [63:0] usCount
);
  localparam NEXT = CPU_CLOCK_FREQ / 1_000_000;
  wire [31:0] counter;
  wire [31:0] nextCounter;
  assign nextCounter = counter + 1;

  REGISTER_R # (
    .N    ( 32                                      )
  ) u_counter (
    .q   	( counter                                 ),
    .d   	( nextCounter                             ),
    .rst 	( rst || (nextCounter == NEXT)            ),
    .clk 	( clk                                     )
  );

  wire [63:0] nextUs;
  assign nextUs = usCount + 1;

  REGISTER_R_CE # (
    .N    ( 64                            )
  ) u_second (
    .q   	( usCount                       ),
    .d   	( nextUs                        ),
    .rst 	( rst                           ),
    .ce  	( nextCounter == NEXT           ),
    .clk 	( clk                           )
  );

endmodule //timer
