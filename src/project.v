/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */
// `timescale 1ns/1ps
`default_nettype none

module tt_um_multiplier (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

	// uart_spi_top top_uut	
	// (
		// .clk(clk),
		// .reset(rst_n),
		// .freq_control(ui_in[1:0]),
		// .uart_rx_d_in(ui_in[2]),
		// .uart_tx_start(ui_in[3]),
		// .cs_bar(ui_in[4]),
		// .sclk(ui_in[5]),
		// .mosi(ui_in[6]),
		// .spi_start(ui_in[7]),
		// .uart_tx_d_out(uo_out[0]),
		// .miso(uo_out[1]),
		// .uart_rx_valid(uo_out[2]),
		// .uart_tx_ready(uo_out[3]),
		// .spi_rx_valid(uo_out[4]),
		// .spi_tx_done(uo_out[5])
	// );
	
	i8bit_mul mul_uut
	(
		.mul_ip_A(ui_in), 
		.mul_ip_B(uio_in), 
		.prod_low(uo_out),
		.prod_high(uio_out)
	);
	
  // assign uio_out = 0;
  assign uio_oe  = 0;
  // assign uo_out[7:6]  = 0;

  // List all unused inputs to prevent warnings
  // wire _unused = &{ena, uio_in, 1'b0};
  wire _unused = &{ena, clk, ena, rst_n, 1'b0};

endmodule
