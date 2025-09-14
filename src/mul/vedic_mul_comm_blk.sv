module vedic_mul_comm_blk 
	(
		clk_int,
		reset,
		rx_d_in,
		uart_tx_start,
		tx_d_out,
		uart_rx_valid,
		uart_tx_ready,
		loopback_test,
		protocol_select
	);
	
	input  logic clk_int;
	input  logic reset;
	input  logic rx_d_in;
	input  logic uart_tx_start;
	output logic tx_d_out;
	output logic uart_rx_valid;
	output logic uart_tx_ready;
	
	generate
			
		uart_rx_tx 
		// #(
			// .BAUD_RATE(24'd4000000),
			// .CLOCK_FREQ(28'd100000000)
		// ) 
		uut1 (
			.clk_int(clk_int),
			.uart_reset(reset),
			.uart_transmit_data(uart_transmit_data),
			.uart_rx_d_in(uart_rx),
			.uart_tx_start(uart_tx_start),
			.uart_tx_d_out(uart_tx),
			.uart_received_data(uart_received_data),
			.uart_rx_valid(uart_rx_valid),
			.uart_tx_ready(uart_tx_ready)
		);
		
		// Instantiate the 8-bit multiplier
		i8bit_mul 
		(
			.mul_ip_A(uart_received_reg[7:0]),
			.mul_ip_B(uart_received_reg[7:0]),
			.s(uart_transmit_reg)
		);
		
		// Instantiate SPI
		spi_master_slave (
			.clk_spi(clk_int),           
			.reset(reset),
			.slave_rx_start,
			.slave_tx_start,
			.dout_miso(rx_d_in), 	
			.cs_bar,       
			.sclk,
			.din_mosi(tx_d_out),	
			.rx_valid,
			.tx_done
		);

	endgenerate
	
	always_comb begin
		uart_clock = clk_int;
		uart_reset = reset;
		
		// if 0, uart is selected and SPI is disabled
		if (protocol_select == 1'b0) begin	
				uart_d_in = rx_d_in;
				dout_miso = 0;
				uart_d_out;
	
	
endmodule