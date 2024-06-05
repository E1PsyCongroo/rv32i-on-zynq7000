module top(
  input [1:0] X0, X1, X2, X3,
  input [1:0] Y,
  output [1:0] F
);
  MuxKey #(
    .NR_KEY(4),
    .KEY_LEN(2),
    .DATA_LEN(2)
  ) i0 (
    .out(F),
    .key(Y),
    .lut({
      2'b00, X0,
      2'b01, X1,
      2'b10, X2,
      2'b11, X3
    })
  );
endmodule
