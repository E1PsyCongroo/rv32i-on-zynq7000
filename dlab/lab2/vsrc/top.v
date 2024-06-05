module top (
  input [7:0] in,
  input en,
  output valid,
  output [2:0] out,
  output [7:0] seg
);
  assign valid = en && (in != 8'b0);
  encode83 i0 (.x(in), .en(en), .y(out));
  seg i1 (.b(out), .en(en), .h(seg[7:1]));
  assign seg[0] = 1'b1;
endmodule //top
