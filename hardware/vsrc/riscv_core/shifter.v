module shifter # (
  parameter DWIDTH = 8,
  parameter SHIFTDWIDTH = $clog2(DWIDTH)
) (
  input [DWIDTH-1:0] din,
  input [SHIFTDWIDTH-1:0] shamt,
  input L_R,
  input A_L,
  output [DWIDTH-1:0] dout
);

  integer i, n;
  reg [DWIDTH-1:0] shift_out [0:SHIFTDWIDTH];

  always @(*) begin
    shift_out[0] = din;
    for (i = 0; i < SHIFTDWIDTH; i = i + 1) begin
      case ({shamt[i], L_R})
        2'b00: shift_out[i+1] = shift_out[i];
        2'b01: shift_out[i+1] = shift_out[i];
        2'b10: begin
          for (n = DWIDTH - 1; n > DWIDTH - 1 - (1<< i); n = n - 1)
            case (A_L)
              1'b0: shift_out[i+1][n] = 1'b0;
              1'b1: shift_out[i+1][n] = din[DWIDTH-1];
            endcase
          for (n = 0; n < DWIDTH - (1 << i); n = n + 1)
            shift_out[i+1][n] = shift_out[i][n+(1<<i)];
        end
        2'b11: begin
          for (n = 0; n < 1 << i; n = n + 1)
            shift_out[i+1][n] = 1'b0;
          for (n = 1 << i; n < DWIDTH; n = n + 1)
            shift_out[i+1][n] = shift_out[i][n-(1<<i)];
        end
      endcase
    end
  end
  assign dout = shift_out[SHIFTDWIDTH];

endmodule //shifter
