module top (
  input clk,
  input clk_control,
  input rst,
  input [7:0] din,
  input serial_in,
  input [2:0] shamt,
  input L_R,
  input A_L,
  input [2:0] control,
  input sel,
  output reg [7:0] dout
);

  wire [7:0] shifter_out, barrel_out, lfsr_out;
  reg barrel_LR, barrel_AL;
  reg [1:0] out_sel;
  shifter shifter_i (
    clk_control,
    control,
    din,
    serial_in,
    shifter_out
  );

  barrelShifter barrelShifter_i (
    din,
    shamt,
    barrel_LR,
    barrel_AL,
    barrel_out
  );

  lfsr lfsr_i (
    clk_control,
    lfsr_out
  );

  always @(posedge clk) begin
    if (rst) begin
      barrel_LR <= 1'b0;
      barrel_AL <= 1'b0;
      out_sel <= 2'b00;
    end
    else begin
      barrel_LR <= L_R ? ~barrel_LR : barrel_LR;
      barrel_AL <= A_L ? ~barrel_AL : barrel_AL;
      if (sel) begin
        case(out_sel)
        2'b00: out_sel <= 2'b01;
        2'b01: out_sel <= 2'b10;
        2'b10: out_sel <= 2'b00;
        default: out_sel <= 2'b00;
        endcase
      end
      else out_sel <= out_sel;
    end
  end

  always @(*) begin
    case(out_sel)
    2'b00: dout = shifter_out;
    2'b01: dout = barrel_out;
    2'b10: dout = lfsr_out;
    default: dout = 8'b0;
    endcase
  end

endmodule //top
