module instCounter (
  input clk,
  input rst,
  input valid,
  output [31:0] instCount
);

  wire [31:0] instCountNext;
  assign instCountNext = instCount + 1;

  REGISTER_R_CE # (
    .N    ( 32            )
  ) u_instCounter (
    .q   	( instCount     ),
    .d   	( instCountNext ),
    .rst 	( rst           ),
    .ce  	( valid         ),
    .clk 	( clk           )
  );

endmodule //instCounter
