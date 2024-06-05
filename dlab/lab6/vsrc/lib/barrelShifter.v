module barrelShifter # (
  parameter WIDTH = 8,
  parameter SHIFTWIDTH = $clog2(WIDTH)
) (
  input [WIDTH-1:0] din,
  input [SHIFTWIDTH-1:0] shamt,
  input L_R,
  input A_L,
  output [WIDTH-1:0] dout
);
  reg [WIDTH-1:0] shift1, shift2, shift4;
  always @(*) begin
    if (shamt[0]) begin
      case (L_R)
      1'b0: begin
        case (A_L)
        1'b0: shift1 = {1'b0, din[WIDTH-1:1]};
        1'b1: shift1 = {din[WIDTH-1], din[WIDTH-1:1]};
        endcase
      end
      1'b1: shift1 = {din[WIDTH-2:0], 1'b0};
      endcase
    end
    else shift1 = din;
    if (shamt[1]) begin
      case (L_R)
      1'b0: begin
        case (A_L)
        1'b0: shift2 = {2'b00, shift1[WIDTH-1:2]};
        1'b1: shift2 = {{2{shift1[WIDTH-1]}}, shift1[WIDTH-1:2]};
        endcase
      end
      1'b1: shift2 = {shift1[WIDTH-3:0], 2'b00};
      endcase
    end
    else shift2 = shift1;
    if (shamt[2]) begin
      case (L_R)
      1'b0: begin
        case (A_L)
        1'b0: shift4 = {4'b0000, shift2[WIDTH-1:4]};
        1'b1: shift4 = {{4{shift2[WIDTH-1]}}, din[WIDTH-1:4]};
        endcase
      end
      1'b1: shift4 = {shift2[WIDTH-5:0], 4'b0000};
      endcase
    end
    else shift4 = shift2;
  end
  assign dout = shift4;
endmodule //barrelShifter
