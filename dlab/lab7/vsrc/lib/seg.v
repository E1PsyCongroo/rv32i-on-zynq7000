module seg (
  input [3:0] b,
  input en,
  output reg [7:0] h
);
  always @(*) begin
    if (en) begin
    case(b)
    4'h0: h = 8'b0000_0011;
    4'h1: h = 8'b1001_1111;
    4'h2: h = 8'b0010_0101;
    4'h3: h = 8'b0000_1101;
    4'h4: h = 8'b1001_1001;
    4'h5: h = 8'b0100_1001;
    4'h6: h = 8'b0100_0001;
    4'h7: h = 8'b0001_1111;
    4'h8: h = 8'b0000_0001;
    4'h9: h = 8'b0001_1001;
    4'hA: h = 8'b0001_0001;
    4'hB: h = 8'b0000_0000;
    4'hC: h = 8'b0110_0011;
    4'hD: h = 8'b0000_0011;
    4'hE: h = 8'b0110_0001;
    4'hF: h = 8'b0111_0001;
    endcase
    end
    else h = 8'b000_00000;
  end

endmodule