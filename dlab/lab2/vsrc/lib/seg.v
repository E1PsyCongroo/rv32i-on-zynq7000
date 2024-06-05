module seg (
  input [2:0] b,
  input en,
  output reg [6:0] h
);
  always @(*) begin
    if (en) begin
    case(b)
    3'd0: h = 7'b000_0001;
    3'd1: h = 7'b100_1111;
    3'd2: h = 7'b001_0010;
    3'd3: h = 7'b000_0110;
    3'd4: h = 7'b100_1100;
    3'd5: h = 7'b010_0100;
    3'd6: h = 7'b010_0000;
    3'd7: h = 7'b000_1111;
    endcase
    end
    else h = 7'b000_0000;
  end

endmodule