// =============================================================================
//  uart_top.v  –  Combined UART Transmitter + Receiver on a single FPGA
//  Board  : EDGE Artix-7 (50 MHz clock)
//  UART   : 9600 8N1
//
//  TX side : Press any of the 5 push-buttons → sends a message over tx pin
//  RX side : Receives ASCII chars on rx pin → controls 10 LEDs
//            '1'-'9','0'  → turn  LED[0-9] ON
//            '!','@','#','$','%','^','&','*','(',')'  → turn LED[0-9] OFF
//
//  Internal loopback (optional):
//    The tx output is also wired back to the rx input internally so you can
//    test without external wiring.  Comment out the loopback line and connect
//    the physical tx→rx pins on the board for real loopback testing.
// =============================================================================

module uart_top (
    input        clk,          // 50 MHz
    input  [4:0] pb,           // push-buttons (PULLDOWN, active-HIGH)
    input        rx,           // UART RX  (from USB-UART bridge / external)
    output       tx,           // UART TX  (to USB-UART bridge / PuTTY)
    output reg [9:0] led       // 10 LEDs
);

// ---------------------------------------------------------------------------
// 0.  Parameters
// ---------------------------------------------------------------------------
localparam CLK_FREQ     = 50_000_000;
localparam BAUD         = 9_600;
localparam DEBOUNCE_MAX = 1_000_000;   // 20 ms @ 50 MHz
localparam MSG_LEN      = 24;
localparam NUM_MSG      = 5;

// ===========================================================================
// 1.  UART TX – submodule instantiation
// ===========================================================================
reg        tx_send = 0;
reg  [7:0] tx_data = 0;
wire       tx_busy;

uart_tx #(
    .CLK_FREQ (CLK_FREQ),
    .BAUD     (BAUD)
) u_tx (
    .clk     (clk),
    .data_in (tx_data),
    .send    (tx_send),
    .tx      (tx),
    .busy    (tx_busy)
);

// ===========================================================================
// 2.  UART RX – submodule instantiation
// ===========================================================================
// ---- choose RX source ----
// Option A : physical pin (default – use when connected to PC or external TX)
wire rx_source = rx;

// Option B : internal loopback (uncomment to test TX→RX without wires)
// wire rx_source = tx;

wire [7:0] rx_data;
wire       rx_ready;

uart_rx #(
    .CLK_FREQ (CLK_FREQ),
    .BAUD     (BAUD)
) u_rx (
    .clk        (clk),
    .rx         (rx_source),
    .data_out   (rx_data),
    .data_ready (rx_ready)
);

// ===========================================================================
// 3.  Button debounce  (20 ms, active-HIGH inputs with PULLDOWN on board)
// ===========================================================================
reg [4:0]  pb_sync0 = 0, pb_sync1 = 0;

always @(posedge clk) begin
    pb_sync0 <= pb;
    pb_sync1 <= pb_sync0;
end

reg [4:0]  pb_clean = 0;
reg [19:0] db_cnt   [4:0];

genvar g;
generate
    for (g = 0; g < 5; g = g + 1) begin : debounce
        always @(posedge clk) begin
            if (pb_sync1[g] == pb_clean[g]) begin
                db_cnt[g] <= 0;
            end else begin
                db_cnt[g] <= db_cnt[g] + 1;
                if (db_cnt[g] == DEBOUNCE_MAX - 1) begin
                    pb_clean[g] <= pb_sync1[g];
                    db_cnt[g]   <= 0;
                end
            end
        end
    end
endgenerate

// Rising-edge detect
reg [4:0] pb_clean_prev = 0;
reg [4:0] pb_edge       = 0;

always @(posedge clk) begin
    pb_clean_prev <= pb_clean;
    pb_edge       <= pb_clean & ~pb_clean_prev;
end

// ===========================================================================
// 4.  Message ROM  (5 × 24 bytes)
// ===========================================================================
reg [7:0] msg_rom [0 : NUM_MSG*MSG_LEN - 1];

initial begin
    // Button 0 (Top) pressed\r\n
    msg_rom[0]="B"; msg_rom[1]="u"; msg_rom[2]="t"; msg_rom[3]="t";
    msg_rom[4]="o"; msg_rom[5]="n"; msg_rom[6]=" "; msg_rom[7]="0";
    msg_rom[8]=" "; msg_rom[9]="("; msg_rom[10]="T";msg_rom[11]="o";
    msg_rom[12]="p";msg_rom[13]=")";msg_rom[14]=" ";msg_rom[15]="p";
    msg_rom[16]="r";msg_rom[17]="e";msg_rom[18]="s";msg_rom[19]="s";
    msg_rom[20]="e";msg_rom[21]="d";msg_rom[22]=8'h0D;msg_rom[23]=8'h0A;

    // Button 1 (Bot) pressed\r\n
    msg_rom[24]="B";msg_rom[25]="u";msg_rom[26]="t";msg_rom[27]="t";
    msg_rom[28]="o";msg_rom[29]="n";msg_rom[30]=" ";msg_rom[31]="1";
    msg_rom[32]=" ";msg_rom[33]="(";msg_rom[34]="B";msg_rom[35]="o";
    msg_rom[36]="t";msg_rom[37]=")";msg_rom[38]=" ";msg_rom[39]="p";
    msg_rom[40]="r";msg_rom[41]="e";msg_rom[42]="s";msg_rom[43]="s";
    msg_rom[44]="e";msg_rom[45]="d";msg_rom[46]=8'h0D;msg_rom[47]=8'h0A;

    // Button 2 (Lft) pressed\r\n
    msg_rom[48]="B";msg_rom[49]="u";msg_rom[50]="t";msg_rom[51]="t";
    msg_rom[52]="o";msg_rom[53]="n";msg_rom[54]=" ";msg_rom[55]="2";
    msg_rom[56]=" ";msg_rom[57]="(";msg_rom[58]="L";msg_rom[59]="f";
    msg_rom[60]="t";msg_rom[61]=")";msg_rom[62]=" ";msg_rom[63]="p";
    msg_rom[64]="r";msg_rom[65]="e";msg_rom[66]="s";msg_rom[67]="s";
    msg_rom[68]="e";msg_rom[69]="d";msg_rom[70]=8'h0D;msg_rom[71]=8'h0A;

    // Button 3 (Rgt) pressed\r\n
    msg_rom[72]="B";msg_rom[73]="u";msg_rom[74]="t";msg_rom[75]="t";
    msg_rom[76]="o";msg_rom[77]="n";msg_rom[78]=" ";msg_rom[79]="3";
    msg_rom[80]=" ";msg_rom[81]="(";msg_rom[82]="R";msg_rom[83]="g";
    msg_rom[84]="t";msg_rom[85]=")";msg_rom[86]=" ";msg_rom[87]="p";
    msg_rom[88]="r";msg_rom[89]="e";msg_rom[90]="s";msg_rom[91]="s";
    msg_rom[92]="e";msg_rom[93]="d";msg_rom[94]=8'h0D;msg_rom[95]=8'h0A;

    // Button 4 (Ctr) pressed\r\n
    msg_rom[96] ="B";msg_rom[97] ="u";msg_rom[98] ="t";msg_rom[99] ="t";
    msg_rom[100]="o";msg_rom[101]="n";msg_rom[102]=" ";msg_rom[103]="4";
    msg_rom[104]=" ";msg_rom[105]="(";msg_rom[106]="C";msg_rom[107]="t";
    msg_rom[108]="r";msg_rom[109]=")";msg_rom[110]=" ";msg_rom[111]="p";
    msg_rom[112]="r";msg_rom[113]="e";msg_rom[114]="s";msg_rom[115]="s";
    msg_rom[116]="e";msg_rom[117]="d";msg_rom[118]=8'h0D;msg_rom[119]=8'h0A;
end

// ===========================================================================
// 5.  TX Controller FSM
// ===========================================================================
localparam TX_IDLE = 2'd0,
           TX_LOAD = 2'd1,
           TX_WAIT = 2'd2;

reg [1:0] tx_state      = TX_IDLE;
reg [4:0] char_idx      = 0;
reg [6:0] rom_base      = 0;
reg       pending       = 0;
reg [6:0] pending_base  = 0;

always @(posedge clk) begin
    tx_send <= 0;   // default: no pulse

    // Latch the highest-priority button press
    if      (pb_edge[0]) begin pending <= 1; pending_base <= 7'd0;  end
    else if (pb_edge[1]) begin pending <= 1; pending_base <= 7'd24; end
    else if (pb_edge[2]) begin pending <= 1; pending_base <= 7'd48; end
    else if (pb_edge[3]) begin pending <= 1; pending_base <= 7'd72; end
    else if (pb_edge[4]) begin pending <= 1; pending_base <= 7'd96; end

    case (tx_state)
        TX_IDLE: begin
            if (pending && !tx_busy) begin
                pending  <= 0;
                rom_base <= pending_base;
                char_idx <= 0;
                tx_state <= TX_LOAD;
            end
        end

        TX_LOAD: begin
            tx_data  <= msg_rom[rom_base + char_idx];
            tx_send  <= 1;          // 1-cycle pulse → starts uart_tx
            tx_state <= TX_WAIT;
        end

        TX_WAIT: begin
            if (!tx_busy) begin
                if (char_idx == MSG_LEN - 1)
                    tx_state <= TX_IDLE;
                else begin
                    char_idx <= char_idx + 1;
                    tx_state <= TX_LOAD;
                end
            end
        end
    endcase
end

// ===========================================================================
// 6.  RX LED Controller
// ===========================================================================
always @(posedge clk) begin
    if (rx_ready) begin
        case (rx_data)
            // Turn ON  ('1' through '0')
            8'h31: led[0] <= 1;
            8'h32: led[1] <= 1;
            8'h33: led[2] <= 1;
            8'h34: led[3] <= 1;
            8'h35: led[4] <= 1;
            8'h36: led[5] <= 1;
            8'h37: led[6] <= 1;
            8'h38: led[7] <= 1;
            8'h39: led[8] <= 1;
            8'h30: led[9] <= 1;
            // Turn OFF  ('!' through ')')
            8'h21: led[0] <= 0;
            8'h40: led[1] <= 0;
            8'h23: led[2] <= 0;
            8'h24: led[3] <= 0;
            8'h25: led[4] <= 0;
            8'h5E: led[5] <= 0;
            8'h26: led[6] <= 0;
            8'h2A: led[7] <= 0;
            8'h28: led[8] <= 0;
            8'h29: led[9] <= 0;
            default: ;
        endcase
    end
end

endmodule
