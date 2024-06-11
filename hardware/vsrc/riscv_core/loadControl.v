module loadControl (
  input [1:0] sum_low,
  input [2:0] ld_type,
  input [31:0] din,
  output reg [31:0] dout
);
  wire [31:0] tmp1 = din >> {sum_low, 3'b0};
  wire [31:0] tmp2 = din >> {sum_low[1], 4'b0};
  always @(*) begin
    case(ld_type)
    `FNC_LB:  dout = {{25{tmp1[7]}}, tmp1[6:0]};
    `FNC_LH:  dout = {{17{tmp2[15]}}, tmp2[14:0]};
    `FNC_LW:  dout = din;
    `FNC_LBU: dout = {24'b0, tmp1[7:0]};
    `FNC_LHU: dout = {16'b0, tmp2[15:0]};
    default:  dout = 32'b0;
    endcase
  end
endmodule //loadControl
