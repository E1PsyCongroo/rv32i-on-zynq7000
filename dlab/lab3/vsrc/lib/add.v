module add # (
  parameter N = 4
) (
  input [N-1:0] ina, inb,
  input cin,
  output [N-1:0] out,
  output cf, of, zf, sf
);
  wire carry;
  wire [N-1:0] t_no_cin;
  assign t_no_cin = {N{cin}} ^ inb;
  assign {carry,out} = ina + t_no_cin + { {(N-1){1'b0}}, cin};
  assign of = (ina[N-1] == t_no_cin[N-1]) && (out[N-1] != ina[N-1]);
  assign cf = carry ^ cin;
  assign zf = ~(| out);
  assign sf = out[N-1];
endmodule