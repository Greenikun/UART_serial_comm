module uart_tx (
  input clk,
  input rst,
  input tx_start,
  input [7:0] tx_data,
  output reg tx,
  output reg tx_busy
);

parameter CLK_PER_BIT = 87; // 115200 baud @ 10 MHz clock

reg [3:0] bit_index = 0;
reg [7:0] shift_reg = 0;
reg [15:0] clk_count = 0;
reg [2:0] state = 0;

localparam IDLE     = 0;
localparam START    = 1;
localparam DATA     = 2;
localparam STOP     = 3;

always @(posedge clk or posedge rst) begin
  if (rst) begin
    state <= IDLE;
    tx <= 1'b1;
    tx_busy <= 0;
    clk_count <= 0;
    bit_index <= 0;
  end else begin
    case (state)
      IDLE: begin
        tx <= 1;
        tx_busy <= 0;
        if (tx_start) begin
          shift_reg <= tx_data;
          state <= START;
          tx_busy <= 1;
        end
      end
      
      START: begin
        tx <= 0;
        if (clk_count < CLK_PER_BIT - 1) begin
          clk_count <= clk_count + 1;
        end else begin
          clk_count <= 0;
          state <= DATA;
        end
      end
      
      DATA: begin
        tx <= shift_reg[bit_index];
        if (clk_count < CLK_PER_BIT - 1) begin
          clk_count <= clk_count + 1;
        end else begin
          clk_count <= 0;
          if (bit_index < 7)
            bit_index <= bit_index + 1;
          else begin
            bit_index <= 0;
            state <= STOP;
          end
        end
      end
      
      STOP: begin
        tx <= 1;
        if (clk_count < CLK_PER_BIT - 1) begin
          clk_count <= clk_count + 1;
        end else begin
          clk_count <= 0;
          state <= IDLE;
          tx_busy <= 0;
        end
      end
    endcase
  end
end

endmodule
