module alu (
  input [3:0] ina, inb,
  input [2:0] op,
  output reg [3:0] out,
  output of, cf
);
  localparam op_add = 3'b000;
  localparam op_sub = 3'b001;
  localparam op_not = 3'b010;
  localparam op_and = 3'b011;
  localparam op_or = 3'b100;
  localparam op_xor = 3'b101;
  localparam op_lt = 3'b110;
  localparam op_eq = 3'b111;
  wire [3:0] add_sub;
  add i0 (.ina(ina), .inb(inb), .cin(op[0]), .out(add_sub), .of(of), .cf(cf), .zf(), .sf());
  always @(*) begin
    case(op)
    op_add: out = add_sub;
    op_sub: out = add_sub;
    op_not: out = ~ina;
    op_and: out = ina & inb;
    op_or:  out = ina | inb;
    op_xor: out = ina ^ inb;
    op_lt:  out = { 3'b0, $signed(ina) < $signed(inb) };
    op_eq:  out = { 3'b0, ina == inb };
    endcase
  end
endmodule
