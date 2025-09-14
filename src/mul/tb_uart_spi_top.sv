`timescale 1ns / 1ns

module tb_uart_spi_top;

    // parameter integer BAUD_RATE = 1500000;
    parameter integer CLOCK_FREQ = 9600;
    parameter real CLK_PERIOD = 104166.66; // 20 ns for 50 MHz
	localparam SCLK_PERIOD = 1000; // SPI clock

	// uart
    logic clk;
    logic reset;
    logic uart_rx_d_in;
    logic uart_tx_start;
    logic uart_tx_d_out;
    logic [1:0] freq_control;
    logic uart_rx_valid;
    logic uart_tx_ready;
	
	// spi
	logic spi_start;
    logic mosi;
	logic cs_bar;
    logic sclk;
    logic miso;
    logic spi_rx_valid;
    logic spi_tx_done;


 uart_spi_top top_uut	(
	.clk(clk),
	.reset(reset),
	.freq_control(freq_control),
	.uart_rx_d_in(uart_rx_d_in),
	.uart_tx_start(uart_tx_start),
	.cs_bar(cs_bar),
	.sclk(sclk),
	.mosi(mosi),
	.spi_start(spi_start),
	.uart_tx_d_out(uart_tx_d_out),
	.miso(miso),
	.uart_rx_valid(uart_rx_valid),
	.uart_tx_ready(uart_tx_ready),
	.spi_rx_valid(spi_rx_valid),
	.spi_tx_done(spi_tx_done)
	);

////////////////////// UART //////////////////////////
    // Generate clock signal
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk; // Generate clock
    end

     // Task to send serial data
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
    
    // Test sequence
    initial begin
        // Initialize signals
        reset = 0;
        uart_rx_d_in = 1'b1;
        uart_tx_start = 1'b1;
        freq_control = 2'b00;
        
        #100 reset = 1'b1;
        
        #200;
        send_serial(8'hA9); // Send byte 0xA5 over UART RX
        
        #200000;
        send_serial(8'h5A); // Send another byte 0x5A over UART RX
        
        #500000;
		uart_tx_start = 1'b0;
		#1000;
		uart_tx_start = 1'b0;
        // $stop;
    end
////////////////////// UART END//////////////////////////


////////////////////// SPI //////////////////////////
initial begin
        sclk = 0;
		forever #(SCLK_PERIOD / 2) sclk = ~sclk;
    end

    // Test miso_reg_data and control signals
    logic [15:0] test_data [0:15];
    integer i;

    initial begin
        // Initialize test miso_reg_data (e.g., 16 frames with varying channel_id)
        for (i = 0; i <=15; i++) begin
            test_data[i] = {12'd0, i[3:0]}; // Channel ID is i, miso_reg_data is 0xABC
        end

        // Initialize signals
        reset = 0;
		cs_bar = 0;
        spi_start = 0;
        mosi = 0;
        // mosi_reg_data = 0;

        // Wait for reset
        #200;
		reset = 1;
		cs_bar = 1;

        // Simulate sending 16 frames of 16-bit miso_reg_data
        for (i = 0; i <=15; i++) begin

			// if (i==0) begin
				// miso_reg_data = 16'hF1F1; // Example 16-bit miso_reg_data value
			// end
			// else begin
				// miso_reg_data = 0;
			// end
			
			@(posedge clk);
            spi_start = 1;

            // Simulate MISO miso_reg_data from the ADC
            repeat (16) begin
                @(negedge sclk); // Wait for falling edge of sclk
				mosi = test_data[i][15]; // Send MSB first
                test_data[i] = test_data[i] << 1; // Shift to next bit
            end

            // Wait for miso_reg_data to be received
            @(posedge clk);
            spi_start = 0;
            while (!spi_rx_valid) @(posedge clk);

			if (i==0) begin
				// slave_tx_start = 0;
				#10000;
			end
			else begin
				mosi = 0;
				#10000; // Delay between frames
			end
		end
    end
////////////////////// SPI END//////////////////////////

endmodule
