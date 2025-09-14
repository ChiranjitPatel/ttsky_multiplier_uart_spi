`timescale 1ns / 1ps

module uart_rx_tx_tb;

    // parameter integer BAUD_RATE = 9600;
    // parameter integer CLOCK_FREQ = 9600;
    // parameter integer CLOCK_FREQ = 10000000;
    parameter real CLK_PERIOD = 20.0; // 20 ns for 50 MHz
    // parameter real CLK_PERIOD = 104166.66; // 20 ns for 50 MHz

    logic clk_int;
    logic uart_reset;
	logic [7:0] uart_transmit_data; // 8-bit transmit data
    logic uart_rx_d_in;
    logic uart_tx_start;
    logic uart_tx_d_out;
    logic loopback;
	logic [1:0] freq_control;
    logic [7:0] uart_received_data;
    logic uart_rx_valid;
    logic uart_tx_ready;

    // Instantiate the uart_rx_tx module
    uart_rx_tx 
	// #(
        // .BAUD_RATE(BAUD_RATE),
        // .CLOCK_FREQ(CLOCK_FREQ)
    // ) 
	uut (
        .clk_int(clk_int),
        .uart_reset(uart_reset),
        // .uart_transmit_data(uart_transmit_data),
        .uart_rx_d_in(uart_rx_d_in),
        .uart_tx_start(uart_tx_start),
        .uart_tx_d_out(uart_tx_d_out),
		.loopback(loopback),
		.freq_control(freq_control),
        // .uart_received_data(uart_received_data),
        .uart_rx_valid(uart_rx_valid),
        .uart_tx_ready(uart_tx_ready)
    );

    // Generate clock signal
    initial begin
        clk_int = 0;
        forever #(CLK_PERIOD / 2) clk_int = ~clk_int; // Generate clock
    end

    // UART loopback
    assign uart_rx_d_in = uart_tx_d_out; // Loop back tx_d_out to rx_d_in

    // Monitor received data
    always @(posedge clk_int) begin
        if (uart_rx_valid) begin
            $display("Received data: %h (%s)", uart_received_data, uart_received_data);
        end
    end


	task send_serial(input [7:0] data);
		int i;
		uart_rx_d_in = 0; // Start bit
		#104160; // Assuming 9600 baud rate (1/9600 sec per bit at 100MHz clock)
		for (i = 0; i < 8; i = i + 1) begin
			uart_rx_d_in = data[i];
			#104160;
		end
		uart_rx_d_in = 1; // Stop bit
		#104160;
	endtask
		
		
    // Simulation process
    initial begin
        uart_reset = 0;
		uart_tx_start = 1'b0;
        uart_transmit_data = 8'h00; // Initialize transmit data
		freq_control = 2'b00;
		loopback = 1'b1;
		
        // Reset release
        #(4 * CLK_PERIOD);
        uart_reset = 1;
		
		

        // Start sending data in a loop
        repeat (1) begin
            // Simulate sending data
            // #50000; // Wait a bit before starting transmission
            // // uart_transmit_data = (uart_transmit_data == 8'h31) ? 8'h30 : 8'h31; // Toggle between ASCII '1' and '0'
			// uart_tx_start = 1'b1;
            // uart_transmit_data = 8'h02; // Toggle between ASCII '1' and '0'
			// wait(uart_tx_ready == 0);
			// uart_tx_start = 1'b0;
            // #10000; // Wait for a bit
            
            // #50000; // Wait a bit before starting transmission
            // // uart_transmit_data = (uart_transmit_data == 8'h31) ? 8'h30 : 8'h31; // Toggle between ASCII '1' and '0'
			// uart_tx_start = 1'b1;
            // uart_transmit_data = 8'h0A; // Toggle between ASCII '1' and '0'
			// wait(uart_tx_ready == 0);
			// uart_tx_start = 1'b0;
            // #10000; // Wait for a bit
			
			// Task to send serial data
		
			send_serial(8'hA9); // Send byte 0xA5 over UART RX
			// wait(uart_tx_ready == 0);
			// uart_tx_start = 1'b0;
			
			// #20000;
			// send_serial(8'h5A);
			// wait(uart_tx_ready == 0);
			// uart_tx_start = 1'b0;
			
			#5000;
			uart_tx_start = 1'b1;
			#1000;
			uart_tx_start = 1'b0;
			
			end
			
			// Allow enough time to observe multiple transmissions
			#(100 * CLK_PERIOD);
			
			
			
		end

endmodule
