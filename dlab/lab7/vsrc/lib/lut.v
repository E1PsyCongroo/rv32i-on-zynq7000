module lut #(
  parameter PATH = "lut.txt",
  parameter ADDRWIDTH = 4,
  parameter DATAWIDTH = 4,
  parameter DEFAULTVAL = 0
) (
  input [ADDRWIDTH-1:0] addr,
  output [DATAWIDTH-1:0] dout
);
  localparam ADDRNUM = $rtoi($pow(2, ADDRWIDTH));
  reg [DATAWIDTH-1:0] lut [0:ADDRNUM-1];

  integer i;
  initial
  begin
    for (i = 0; i < ADDRNUM; i = i + 1) begin
      lut[i] = DEFAULTVAL;
    end
    $readmemh(PATH, lut, 0, ADDRNUM-1);
  end
  assign dout = lut[addr];

endmodule // lut
