module SimReg # (
  parameter WIDTH = 4,
  parameter INITSTATE = 0
) (
  input clk,
  input reset,
  input [WIDTH-1:0] state_din,
  output reg [WIDTH-1:0] state_dout,
  input state_wen
);
  always @(posedge clk) begin
    if (reset) begin
      state_dout <= INITSTATE;
    end
    else if (state_wen) begin
      state_dout <= state_din;
    end
  end
endmodule