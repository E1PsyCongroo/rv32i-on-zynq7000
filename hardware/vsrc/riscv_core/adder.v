module adder # (
  parameter DWIDTH = 4
) (
  input [DWIDTH-1:0] ina, inb,
  input cin,
  output [DWIDTH-1:0] out,
  output cf, of, zf, sf
);
  wire carry;
  wire [DWIDTH-1:0] t_no_cin;
  assign t_no_cin = {DWIDTH{cin}} ^ inb;
  assign {carry,out} = ina + t_no_cin + { {(DWIDTH-1){1'b0}}, cin};
  assign of = (ina[DWIDTH-1] == t_no_cin[DWIDTH-1]) && (out[DWIDTH-1] != ina[DWIDTH-1]);
  assign cf = carry ^ cin;
  assign zf = ~(| out);
  assign sf = out[DWIDTH-1];
endmodule