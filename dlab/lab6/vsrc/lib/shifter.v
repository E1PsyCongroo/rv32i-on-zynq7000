module shifter # (
  parameter WIDTH = 8
) (
  input clk,
  input [2:0] control,
  input [WIDTH-1:0] din,
  input serial_in,
  output [WIDTH-1:0] dout
);
  reg [WIDTH-1:0] Q;
  always @(posedge clk) begin
    case(control)
    3'b000: Q <= {WIDTH{1'b0}};
    3'b001: Q <= din;
    3'b010: Q <= {1'b0, Q[WIDTH-1:1]};
    3'b011: Q <= {Q[WIDTH-2:0], 1'b0};
    3'b100: Q <= {Q[WIDTH-1], Q[WIDTH-1:1]};
    3'b101: Q <= {serial_in, Q[WIDTH-1:1]};
    3'b110: Q <= {Q[0], Q[WIDTH-1:1]};
    3'b111: Q <= {Q[WIDTH-2:0], Q[WIDTH-1]};
    endcase
  end
  assign dout = Q;
endmodule //shifter
