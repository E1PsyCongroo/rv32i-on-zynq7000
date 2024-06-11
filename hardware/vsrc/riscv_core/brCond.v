`include "opcode.vh"
module brCond (
  input [31:0] ina, inb,
  input [2:0] br_type,
  output reg br_taken
);

  wire eq = ina == inb;
  wire lt = $signed(ina) < $signed(inb);
  wire ltu = ina < inb;
  always @(*) begin
    case (br_type)
    `FNC_BEQ:   br_taken = eq;
    `FNC_BNE:   br_taken = ~eq;
    `FNC_BLT:   br_taken = lt;
    `FNC_BGE:   br_taken = ~lt;
    `FNC_BLTU:  br_taken = ltu;
    `FNC_BGEU:  br_taken = ~ltu;
    default:    br_taken = 1'b0;
    endcase
  end

endmodule