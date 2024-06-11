module storeControl (
  input [1:0] sum_low,
  input [2:0] st_type,
  input [31:0] din,
  output reg [3:0] wbe,
  output [31:0] dout
);

  assign dout = din << {sum_low, 3'b0};
  always @(*) begin
    case(st_type)
    `FNC_SB: wbe = 4'b0001 << sum_low;
    `FNC_SH: wbe = 4'b0011 << sum_low;
    `FNC_SW: wbe = 4'b1111;
    default: wbe = 4'b0000;
    endcase
  end

endmodule