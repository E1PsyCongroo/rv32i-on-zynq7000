module top (
  input clk,
  input rst,
  input ps2_clk, ps2_data,
  output overflow,
  output reg [7:0] code,
  output [7:0] seg0, seg1, seg2, seg3, seg4, seg5
);

  wire ready;
  wire [7:0] data, ascii;
  reg nextdata_n;
  reg clr;
  reg [7:0] count;
  ps2_keyboard i0 (
    ~clk, ~rst, ps2_clk, ps2_data,
    nextdata_n,
    data,
    ready,
    overflow
  );

  lut #(
    .PATH("/home/focused_xy/cs/ysyx-workbench/dlab/lab7/vsrc/code2ascii.hex"),
    .ADDRWIDTH(8),
    .DATAWIDTH(8)
  ) code2ascii_i (
    .addr(code),
    .dout(ascii)
  );

  seg seg0_i (code[3:0], 1'b1, seg0);
  seg seg1_i (code[7:4], 1'b1, seg1);
  seg seg2_i (ascii[3:0], 1'b1, seg2);
  seg seg3_i (ascii[7:4], 1'b1, seg3);
  seg seg4_i (count[3:0], 1'b1, seg4);
  seg seg5_i (count[7:4], 1'b1, seg5);

  always @(posedge clk) begin
    if (rst) begin
      code <= 8'h0;
      nextdata_n <= 1'b1;
      clr <= 1'b0;
      count <= 8'h0;
    end
    else if (ready && nextdata_n) begin
      if (clr) begin
        code <= 8'h0;
        clr <= 1'b0;
      end
      else if (data == 8'hF0) begin
        clr <= 1'b1;
      end
      else begin
        if (code != data) count <= count + 1;
        code <= data;
      end
      nextdata_n <= 1'b0;
    end
    else begin
      code <= code;
      nextdata_n <= 1'b1;
    end
  end


endmodule