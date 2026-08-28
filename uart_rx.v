// =============================================================================
//  uart_rx.v  –  UART Receiver  (8N1, parameterised baud)
//  No changes from original – kept as a clean submodule.
// =============================================================================

module uart_rx (
    input            clk,
    input            rx,
    output reg [7:0] data_out,
    output reg       data_ready
);

parameter CLK_FREQ = 50_000_000;
parameter BAUD     = 9_600;
localparam CLKS_PER_BIT = CLK_FREQ / BAUD;   // 5208
localparam HALF_BIT     = CLKS_PER_BIT / 2;  // 2604

reg [12:0] clk_count = 0;
reg [3:0]  bit_index = 0;
reg [7:0]  rx_shift  = 0;
reg        rx_sync0  = 1;
reg        rx_sync1  = 1;

localparam IDLE  = 2'd0,
           START = 2'd1,
           DATA  = 2'd2,
           STOP  = 2'd3;

reg [1:0] state = IDLE;

always @(posedge clk) begin
    rx_sync0   <= rx;
    rx_sync1   <= rx_sync0;
    data_ready <= 0;

    case (state)
        IDLE: begin
            clk_count <= 0;
            bit_index <= 0;
            if (rx_sync1 == 0)
                state <= START;
        end

        START: begin
            if (clk_count < HALF_BIT - 1)
                clk_count <= clk_count + 1;
            else begin
                clk_count <= 0;
                state     <= (rx_sync1 == 0) ? DATA : IDLE;
            end
        end

        DATA: begin
            if (clk_count < CLKS_PER_BIT - 1)
                clk_count <= clk_count + 1;
            else begin
                clk_count          <= 0;
                rx_shift[bit_index] <= rx_sync1;
                if (bit_index < 7)
                    bit_index <= bit_index + 1;
                else begin
                    bit_index <= 0;
                    state     <= STOP;
                end
            end
        end

        STOP: begin
            if (clk_count < CLKS_PER_BIT - 1)
                clk_count <= clk_count + 1;
            else begin
                clk_count  <= 0;
                data_out   <= rx_shift;
                data_ready <= 1;
                state      <= IDLE;
            end
        end
    endcase
end

endmodule
