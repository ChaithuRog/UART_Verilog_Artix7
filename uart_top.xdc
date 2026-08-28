## =============================================================================
##  uart_top.xdc  –  EDGE Artix-7  |  Combined UART TX + RX project
##  Top module : uart_top
##  Ports      : clk, pb[4:0], rx, tx, led[9:0]
## =============================================================================

# --- Clock 50 MHz ---
set_property -dict { PACKAGE_PIN N11 IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports { clk }];

# --- Push Buttons (PULLDOWN on board, active-HIGH) ---
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {pb[0]}]; # Top
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {pb[1]}]; # Bottom
set_property -dict {PACKAGE_PIN M12 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {pb[2]}]; # Left
set_property -dict {PACKAGE_PIN L13 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {pb[3]}]; # Right
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {pb[4]}]; # Center

# --- USB UART TX  (connect to PuTTY at 9600 8N1) ---
set_property -dict { PACKAGE_PIN C4 IOSTANDARD LVCMOS33 } [get_ports {tx}];

# --- USB UART RX ---
set_property -dict { PACKAGE_PIN D4 IOSTANDARD LVCMOS33 } [get_ports {rx}];

# --- LEDs ---
set_property -dict { PACKAGE_PIN J3 IOSTANDARD LVCMOS33 } [get_ports {led[0]}];
set_property -dict { PACKAGE_PIN H3 IOSTANDARD LVCMOS33 } [get_ports {led[1]}];
set_property -dict { PACKAGE_PIN J1 IOSTANDARD LVCMOS33 } [get_ports {led[2]}];
set_property -dict { PACKAGE_PIN K1 IOSTANDARD LVCMOS33 } [get_ports {led[3]}];
set_property -dict { PACKAGE_PIN L3 IOSTANDARD LVCMOS33 } [get_ports {led[4]}];
set_property -dict { PACKAGE_PIN L2 IOSTANDARD LVCMOS33 } [get_ports {led[5]}];
set_property -dict { PACKAGE_PIN K3 IOSTANDARD LVCMOS33 } [get_ports {led[6]}];
set_property -dict { PACKAGE_PIN K2 IOSTANDARD LVCMOS33 } [get_ports {led[7]}];
set_property -dict { PACKAGE_PIN K5 IOSTANDARD LVCMOS33 } [get_ports {led[8]}];
set_property -dict { PACKAGE_PIN P6 IOSTANDARD LVCMOS33 } [get_ports {led[9]}];
