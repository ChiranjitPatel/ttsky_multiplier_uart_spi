// `timescale 1ns / 1ps

module uart_rx_tx 
	// #(  parameter [23:0] BAUD_RATE = 24'd9600,
		// parameter [27:0] CLOCK_FREQ = 28'd9600
	// )
	(	clk_int,
		uart_reset,
		uart_rx_d_in,
		uart_tx_start,
		loopback,
		freq_control,
		uart_tx_d_out,
		uart_rx_valid,
		uart_tx_ready
	);
	
	
	input  logic clk_int;
	input  logic uart_reset;
	input  logic uart_rx_d_in;
	input  logic uart_tx_start;
	input  logic loopback;
	input  logic [1:0] freq_control;
	output logic uart_tx_d_out;
	output logic uart_rx_valid;
	output logic uart_tx_ready;
	
	logic  [7:0] uart_transmit_data;
	logic  [7:0] uart_received_data;
	
	// Instantiate uart_tx
	uart_tx 
	// #(
		// .baud_rate(BAUD_RATE),
		// .clock_freq(CLOCK_FREQ)
	// ) 
	uart_tx_inst (
		.uart_clock(clk_int),
		.uart_reset(uart_reset),
		.uart_start(uart_tx_start),
		.uart_d_in(uart_transmit_data),
		.freq_control(freq_control),
		.uart_d_out(uart_tx_d_out),
		.uart_tx_ready(uart_tx_ready)
	);

	// Instantiate uart_rx 
	uart_rx 
	// #(
		// .baud_rate(BAUD_RATE),
		// .clock_freq(CLOCK_FREQ)
	// ) 
	uart_rx_inst (
		.uart_clock(clk_int),
		.uart_reset(uart_reset),
		.uart_d_in(uart_rx_d_in),
		.freq_control(freq_control),
		.uart_d_out(uart_received_data),
		.uart_valid(uart_rx_valid)
	);

	always_latch begin	
		if (loopback ==1)
			uart_transmit_data = uart_received_data;
		 
	end
	
endmodule
