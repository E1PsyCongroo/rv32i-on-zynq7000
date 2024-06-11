`include "opcode.vh"
module alu (
  input [31:0] ina, inb,
  input as_inb,
  input [3:0] op,
  output [31:0] sum,
  output reg [31:0] out,
  output [3:0] fr
);

  adder # (
    .DWIDTH(32)
  ) u_adder (
    .ina(ina), .inb(inb), .cin(op[3]), .out(sum),
    .zf(fr[3]), .sf(fr[2]), .cf(fr[1]), .of(fr[0])
  );

  wire [31:0] shifter_out;
  shifter # (
    .DWIDTH(32)
  ) u_shifter (
    .din(ina),
    .shamt(inb[4:0]),
    .L_R(~op[2]),
    .A_L(op[3]),
    .dout(shifter_out)
  );

  always @(*) begin
    if (as_inb) out = inb;
    else begin
      case(op[2:0])
      `FNC_ADD_SUB  : out = sum;
      `FNC_SLL      : out = shifter_out;
      `FNC_SLT      : out = { 31'b0, $signed(ina) < $signed(inb) };
      `FNC_SLTU     : out = { 31'b0, ina < inb };
      `FNC_XOR      : out = ina ^ inb;
      `FNC_OR       : out = ina | inb;
      `FNC_AND      : out = ina & inb;
      `FNC_SRL_SRA  : out = shifter_out;
      default       : out = 32'b0;
      endcase
    end
  end
endmodule
