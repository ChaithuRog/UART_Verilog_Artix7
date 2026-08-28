// =============================================================================
//  uart_tx.v  –  UART Transmitter  (8N1, parameterised baud)
//  No changes from original – kept as a clean submodule.
// =============================================================================

module uart_tx (
    input            clk,
    input      [7:0] data_in,
    input            send,
    output reg       tx,
    output reg       busy
);

parameter CLK_FREQ = 50_000_000;
parameter BAUD     = 9_600;
localparam CLKS_PER_BIT = CLK_FREQ / BAUD;   // 5208 @ 50 MHz / 9600

reg [12:0] clk_count = 0;
reg [3:0]  bit_index = 0;
reg [9:0]  tx_shift  = 10'b1111111111;

initial tx   = 1'b1;
initial busy = 1'b0;

always @(posedge clk) begin
    if (!busy) begin
        tx <= 1'b1;
        if (send) begin
            tx_shift  <= {1'b1, data_in, 1'b0};  // stop | data[7:0] | start
            clk_count <= 0;
            bit_index <= 0;
            busy      <= 1;
        end
    end else begin
        if (clk_count < CLKS_PER_BIT - 1) begin
            clk_count <= clk_count + 1;
        end else begin
            clk_count <= 0;
            tx        <= tx_shift[bit_index];
            if (bit_index < 9)
                bit_index <= bit_index + 1;
            else begin
                bit_index <= 0;
                busy      <= 0;
            end
        end
    end
end

endmodule
