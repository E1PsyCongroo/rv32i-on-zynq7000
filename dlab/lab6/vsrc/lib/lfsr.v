module lfsr # (
  parameter WIDTH = 8
) (
  input clk,
  output [WIDTH-1:0] dout
);

  wire [2:0] control;
  wire [WIDTH-1:0] din;
  wire serial_in;
  shifter #(WIDTH) shifter_i (
    clk,
    control,
    din,
    serial_in,
    dout
  );
  assign control = (dout != 0) ? 3'b101 : 3'b001;
  assign din = (dout != 0) ? 0 : 1;
  assign serial_in = ^ dout[3:0];
endmodule //lfsr
