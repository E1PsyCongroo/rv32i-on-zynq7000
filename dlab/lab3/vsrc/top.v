module top (
  input [3:0] ina, inb,
  input [2:0] op,
  output [3:0] out,
  output of, cf
);
  alu i0 (ina, inb, op, out, of, cf);
endmodule