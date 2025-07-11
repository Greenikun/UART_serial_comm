`timescale 1ns/1ps // time/percision

module uart_tx_tb;

reg clk = 0;
reg rst = 0;
reg tx_start = 0;
reg [7:0] tx_data = 0;
wire tx;
wire tx_busy;

uart_tx uut (
  .clk(clk),
  .rst(rst),
  .tx_start(tx_start),
  .tx_data(tx_data),
  .tx(tx),
  .tx_busy(tx_busy)
);

always #5 clk = ~clk; // 10ns clock (100MHz)

initial begin
  $dumpfile("uart_tx.vcd");
  $dumpvars(0, uart_tx_tb);
  
  rst = 1; #20;
  rst = 0;
  
  tx_data = 8'b10101010; // Data to transmit
  tx_start = 1; #10;
  tx_start = 0;

  #1000;
  $finish;
end

endmodule
