module encode83 (
  input [7:0] x,
  input en,
  output reg [2:0] y
);
  always @(*) begin
    if (en) begin
      y = 3'd0;
      for (integer i = 0; i < 8; i++) begin
        if (x[i] == 1'b1) y = i[2:0];
      end
    end
    else begin
      y = 3'd0;
    end
  end
endmodule //encode83
