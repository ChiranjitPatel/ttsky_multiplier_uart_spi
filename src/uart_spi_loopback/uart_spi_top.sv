// `timescale 1ns/1ps

module uart_spi_top 
	(
	clk,
	reset,
	freq_control,
	uart_rx_d_in,
	uart_tx_start,
	cs_bar,
	sclk,
	mosi,
	spi_start,
	uart_tx_d_out,
	miso,
	uart_rx_valid,
	uart_tx_ready,
	spi_rx_valid,
	spi_tx_done
	);

	input logic clk;
	input logic reset;
	input logic [1:0] freq_control;
	input logic uart_rx_d_in;
	input logic uart_tx_start;
	input logic cs_bar;
	input logic mosi;
	input logic spi_start;
	output logic uart_tx_d_out;
	output logic miso;
	output logic sclk;
	output logic uart_rx_valid;
	output logic uart_tx_ready;
	output logic spi_rx_valid;
	output logic spi_tx_done;
	// output logic frames_received;

    // logic [7:0] miso_reg_data;
    // logic [7:0] mosi_reg_data;

	
	// Instantiate the UART module
    uart_rx_tx dut_uart (
        .clk(clk),
        .reset(reset),
        .uart_rx_d_in(uart_rx_d_in),
        .uart_tx_start(uart_tx_start),
		.freq_control(freq_control),
        .uart_tx_d_out(uart_tx_d_out),
        .uart_rx_valid(uart_rx_valid),
        .uart_tx_ready(uart_tx_ready)
    );

	// Instantiate the SPI module
	spi_master_slave_v3_clk_crtl dut_spi (
        .clk(clk),           
		.reset(reset),
        .slave_rx_start(slave_rx_start),
        .slave_tx_start(slave_tx_start),
        .mosi(mosi),
        .freq_control(freq_control),
        .cs_bar(cs_bar),
        .sclk(sclk),
        .miso(miso),
        .rx_valid(rx_valid),
        .tx_done(tx_done)
    );

endmodule

