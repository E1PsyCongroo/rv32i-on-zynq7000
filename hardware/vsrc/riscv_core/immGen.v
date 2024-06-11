`include "opcode.vh"
module immGen (
  input [31:0] inst,
  output reg [31:0] imm
);
  wire [6:0] opcode = inst[6:0];
  always @(*) begin
    case (opcode)
    // CSR instructions
    `OPC_CSR:       imm = {27'b0, inst[19:15]};

    // Special immediate instructions
    `OPC_LUI:       imm = {inst[31:12], 12'b0};
    `OPC_AUIPC:     imm = {inst[31:12], 12'b0};

    // Jump instructions
    `OPC_JAL:       imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
    `OPC_JALR:      imm = {{21{inst[31]}}, inst[30:20]};

    // Branch instructions
    `OPC_BRANCH:    imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};

    // Load and store instructions
    `OPC_STORE:     imm = {{21{inst[31]}}, inst[30:25], inst[11:7]};
    `OPC_LOAD:      imm = {{21{inst[31]}}, inst[30:20]};

    // Arithmetic instructions
    `OPC_ARI_ITYPE: imm = {{21{inst[31]}}, inst[30:20]};
    default:        imm = 32'b0;
    endcase
  end

endmodule