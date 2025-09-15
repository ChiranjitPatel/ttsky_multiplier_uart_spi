// `timescale 1ns/1ns

// module tb_tt_um_uart_spi;

    // logic [7:0] ui_in;    // Dedicated inputs
    // logic [7:0] uo_out;   // Dedicated outputs
    // logic [7:0] uio_in;   // IOs: Input path
    // logic [7:0] uio_out;  // IOs: Output path
    // logic [7:0] uio_oe;   // IOs: Enable path
    // logic ena;            // Always 1
    // logic clk;            // Clock
    // logic rst_n;          // Reset (active low)

    // tt_um_uart_spi dut (
        // .ui_in(ui_in),
        // .uo_out(uo_out),
        // .uio_in(uio_in),
        // .uio_out(uio_out),
        // .uio_oe(uio_oe),
        // .ena(ena),
        // .clk(clk),
        // .rst_n(rst_n)
    // );

    // always #10 clk = ~clk;  // 50 MHz clock (period 20 ns)

    // logic [7:0] uart_tx_data;
    // logic [7:0] uart_rx_received;
    // logic [15:0] spi_tx_data;
    // logic [15:0] spi_rx_received;
    // integer bit_idx;
    // real bit_time;  // UART bit time in ns

    // initial begin
        // clk = 0;
        // rst_n = 0;
        // ena = 1;
        // ui_in = 0;
        // uio_in = 0;
        // #40;
        // rst_n = 1;
        // #40;

        // // Set frequency control (e.g., 2'b01 for 115200 baud UART / 25 MHz SPI)
        // ui_in[1:0] = 2'b01;

        // // Calculate UART bit time (pulse_duration * clock period)
        // // For freq_control=2'b01, pulse_duration=434, clock period=20 ns -> bit_time ~8680 ns
        // bit_time = 434 * 20.0;

        // // Test 1: UART loopback
        // $display("Starting UART loopback test...");
        // ui_in[7] = 1;  // loopback=1
        // uart_tx_data = 8'hA5;  // Data to send via RX (will be echoed via TX)

        // // Simulate sending serial data on uart_rx_d_in (ui_in[2])
        // ui_in[2] = 0;  // Start bit
        // #(bit_time);
        // for (bit_idx = 0; bit_idx < 8; bit_idx++) begin
            // ui_in[2] = uart_tx_data[bit_idx];
            // #(bit_time);
        // end
        // ui_in[2] = 1;  // Stop bit
        // #(bit_time);

        // // Wait for rx_valid (uo_out[2])
        // wait(uo_out[2] == 1);
        // #20;
        // $display("UART RX valid asserted.");

        // // Trigger TX to echo the data
        // ui_in[3] = 1;  // uart_tx_start=1
        // #20;
        // ui_in[3] = 0;

        // // Collect serial data on uart_tx_d_out (uo_out[0])
        // uart_rx_received = 0;
        // wait(uo_out[0] == 0);  // Wait for start bit
        // #(bit_time / 2);  // Sample in middle of bit
        // for (bit_idx = 0; bit_idx < 8; bit_idx++) begin
            // #(bit_time);
            // uart_rx_received[bit_idx] = uo_out[0];
        // end
        // #(bit_time);  // Stop bit

        // if (uart_rx_received == uart_tx_data)
            // $display("UART loopback test passed: sent %h, received %h", uart_tx_data, uart_rx_received);
        // else
            // $display("UART loopback test failed: sent %h, received %h", uart_tx_data, uart_rx_received);

        // #200;

        // // Test 2: SPI loopback
        // $display("Starting SPI loopback test...");
        // ui_in[7] = 1;  // loopback=1
        // ui_in[4] = 1;  // cs_bar=1 (as required for start)
        // spi_tx_data = 16'hA55A;  // Data to send via MOSI (will be echoed via MISO)

        // // Trigger RX to receive data into internal reg
        // uio_in[0] = 1;  // slave_rx_start=1
        // #20;
        // uio_in[0] = 0;

        // // Drive MOSI (ui_in[5]) - set first bit immediately (CPHA=0)
        // bit_idx = 15;  // MSB first
        // ui_in[5] = spi_tx_data[bit_idx];
        // bit_idx--;
        // wait(uo_out[6] == 1);  // Wait for SCLK start (idle high)
        // while (bit_idx >= 0) begin
            // @(negedge uo_out[6]);  // Drive on negedge SCLK
            // ui_in[5] = spi_tx_data[bit_idx];
            // bit_idx--;
        // end

        // // Wait for rx_valid (uo_out[4])
        // wait(uo_out[4] == 1);
        // #20;
        // $display("SPI RX valid asserted.");

        // // Trigger TX to echo the data on MISO
        // uio_in[1] = 1;  // slave_tx_start=1
        // #20;
        // uio_in[1] = 0;

        // // Collect data on MISO (uo_out[1]), sample on posedge SCLK
        // spi_rx_received = 0;
        // bit_idx = 0;
        // wait(uo_out[6] == 1);  // Synchronize
        // while (bit_idx < 16) begin
            // @(posedge uo_out[6]);  // Sample on posedge
            // spi_rx_received = {spi_rx_received[14:0], uo_out[1]};
            // bit_idx++;
        // end
        // wait(uo_out[5] == 1);  // tx_done
        // #20;

        // if (spi_rx_received == spi_tx_data)
            // $display("SPI loopback test passed: sent %h, received %h", spi_tx_data, spi_rx_received);
        // else
            // $display("SPI loopback test failed: sent %h, received %h", spi_tx_data, spi_rx_received);

        // // Additional test: Simultaneous UART and SPI (brief check)
        // $display("Starting simultaneous UART+SPI test...");
        // // Reuse previous settings, trigger both
        // // For brevity, just check no conflicts (e.g., run both sequences in parallel if needed)

        // #1000;
        // $finish;
    // end

// endmodule


`timescale 1ns/1ns

module tb_tt_um_uart_spi;

    logic [7:0] ui_in;    // Dedicated inputs
    logic [7:0] uo_out;   // Dedicated outputs
    logic [7:0] uio_in;   // IOs: Input path
    logic [7:0] uio_out;  // IOs: Output path
    logic [7:0] uio_oe;   // IOs: Enable path
    logic ena;            // Always 1
    logic clk;            // Clock
    logic rst_n;          // Reset (active low)

    tt_um_uart_spi dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    always #10 clk = ~clk;  // 50 MHz clock (period 20 ns)

    logic [7:0] uart_tx_data;
    logic [7:0] uart_rx_received;
    logic [15:0] spi_tx_data;
    logic [15:0] spi_rx_received;
    integer bit_idx;
    real bit_time;  // UART bit time in ns

    initial begin
        $dumpfile("tb_tt_um_uart_spi.vcd");
        $dumpvars(0, tb_tt_um_uart_spi);
        $monitor("time=%0t, sclk=%b, cs_bar=%b, slave_rx_start=%b, slave_tx_start=%b, rx_valid=%b, tx_done=%b", $time, uo_out[6], ui_in[4], uio_in[0], uio_in[1], uo_out[4], uo_out[5]);

        clk = 0;
        rst_n = 0;
        ena = 1;
        ui_in = 0;
        uio_in = 0;
        #40;
        rst_n = 1;
        #40;

        // Set frequency control to 2'b10 for CLK_DIV=4 (slower SCLK for easier debugging)
        ui_in[1:0] = 2'b10;

        // Calculate UART bit time (for freq_control=2'b10, pulse_duration=50, clock period=20 ns -> bit_time=1000 ns)
        bit_time = 50 * 20.0;

        // Test 1: UART loopback (unchanged)
        $display("Starting UART loopback test...");
        ui_in[7] = 0;  // loopback=1
        uart_tx_data = 8'hA5;

        ui_in[2] = 0;  // Start bit
        #(bit_time);
        for (bit_idx = 0; bit_idx < 8; bit_idx++) begin
            ui_in[2] = uart_tx_data[bit_idx];
            #(bit_time);
        end
        ui_in[2] = 1;  // Stop bit
        #(bit_time);

        wait(uo_out[2] == 1);
        #20;
        $display("UART RX valid asserted.");

        ui_in[3] = 1;  // uart_tx_start=1
        #20;
        ui_in[3] = 0;

        uart_rx_received = 0;
        wait(uo_out[0] == 0);  // Wait for start bit
        #(bit_time / 2);
        for (bit_idx = 0; bit_idx < 8; bit_idx++) begin
            #(bit_time);
            uart_rx_received[bit_idx] = uo_out[0];
        end
        #(bit_time);  // Stop bit

        if (uart_rx_received == uart_tx_data)
            $display("UART loopback test passed: sent %h, received %h", uart_tx_data, uart_rx_received);
        else
            $display("UART loopback test failed: sent %h, received %h", uart_tx_data, uart_rx_received);

        #200;

///////////////////////////////////////////////////////////////////////////////////////////////

        // SPI Tests with different cs_bar values for debugging
		rst_n = 0;
        ui_in[7] = 0;  // loopback
		uio_in[0] = 0; // slave_rx_start
        uio_in[1] = 0; // slave_rx_start
		ui_in[1:0] = 2'b01; // freq_control
		ui_in[4] = 1;  // cs_bar=1
		#40;

        rst_n = 1;
		#40;

        // Test 2a: SPI loopback with cs_bar=1 (as per DUT condition & cs_bar)
        $display("Starting SPI loopback test with cs_bar=1...");

        // @(posedge clk);  // Sync trigger to posedge
        uio_in[0] = 1;  // slave_rx_start=1
        #20;
        uio_in[0] = 0;
		bit_idx = 15;
		
		spi_tx_data = 16'hA55A;
		
		@(negedge uo_out[6])
		ui_in[5] = spi_tx_data[bit_idx];  //mosi = ...
		bit_idx--;
		
		while (bit_idx >= 0) begin
                @(negedge uo_out[6]);
                ui_in[5] = spi_tx_data[bit_idx];
                bit_idx--;
        end
		
		wait (uo_out[4]);
		#20;
		
		#400;
		
		// Test 3a: SPI loopback with cs_bar=1 (as per DUT condition & cs_bar)
        $display("Starting SPI loopback test with cs_bar=1...");

        // @(posedge clk);  // Sync trigger to posedge
        uio_in[0] = 1;  // slave_rx_start=1
        #20;
        uio_in[0] = 0;
		bit_idx = 15;
		
		spi_tx_data = 16'hA55A;
		
		@(negedge uo_out[6])
		ui_in[5] = spi_tx_data[bit_idx];  //mosi = ...
		bit_idx--;
		
		while (bit_idx >= 0) begin
                @(negedge uo_out[6]);
                ui_in[5] = spi_tx_data[bit_idx];
                bit_idx--;
        end
		
		wait (uo_out[4]);
		#20;
		
		#400;
		
        // // Wait for SCLK to start with timeout
        // fork
            // begin
                // wait(uo_out[6] == 0);
                // $display("SCLK started toggling (detected negedge).");
            // end
            // begin
                // #2000;  // Timeout after 2000 ns (~100 clock cycles)
                // $display("Timeout: SCLK did not start toggling with cs_bar=1.");
            // end
        // join_any

		
        // // If started, drive remaining bits
        // if (uo_out[6] == 0 || uo_out[6] == 1) begin  // Proceed if toggled at least once
            // while (bit_idx >= 0) begin
                // @(negedge uo_out[6]);
                // ui_in[5] = spi_tx_data[bit_idx];
                // bit_idx--;
            // end

            // // Wait for rx_valid with timeout
            // fork
                // begin
                    // wait(uo_out[4] == 1);
                    // $display("SPI RX valid asserted with cs_bar=1.");
                // end
                // begin
                    // #10000;  // Longer timeout for slow clock
                    // $display("Timeout: rx_valid not asserted with cs_bar=1.");
                // end
            // join_any
        // end
		
        // // TX part (similarly with timeout)
        // @(posedge clk);
        // uio_in[0] = 1;  // slave_tx_start=1
        // uio_in[1] = 1;  // slave_tx_start=1
        // #20;
        // uio_in[0] = 0;
        // uio_in[1] = 0;

		// #100;
		// ui_in[7] = 1;  // loopback=1
		
        // fork
            // begin
                // wait(uo_out[6] == 0);
                // $display("SCLK started for TX with cs_bar=1.");
            // end
            // begin
                // #2000;
                // $display("Timeout: SCLK did not start for TX with cs_bar=1.");
            // end
        // join_any

        // spi_rx_received = 0;
        // bit_idx = 0;
        // while (bit_idx < 16) begin
            // @(posedge uo_out[6]);
            // spi_rx_received = {spi_rx_received[14:0], uo_out[1]};
            // bit_idx++;
        // end
        // wait(uo_out[5] == 1);
        // #20;

        // if (spi_rx_received == spi_tx_data)
            // $display("SPI test with cs_bar=1 passed: sent %h, received %h", spi_tx_data, spi_rx_received);
        // else
            // $display("SPI test with cs_bar=1 failed: sent %h, received %h", spi_tx_data, spi_rx_received);

        // #200;

        // // Test 2b: SPI loopback with cs_bar=0 (in case condition should be ~cs_bar)
        // $display("Starting SPI loopback test with cs_bar=0 (debug alternative)...");
        // ui_in[4] = 0;  // cs_bar=0

        // bit_idx = 15;
        // ui_in[5] = spi_tx_data[bit_idx];
        // bit_idx--;

        // @(posedge clk);
        // uio_in[0] = 1;
        // #20;
        // uio_in[0] = 0;

        // fork
            // begin
                // wait(uo_out[6] == 0);
                // $display("SCLK started toggling (detected negedge).");
            // end
            // begin
                // #2000;
                // $display("Timeout: SCLK did not start toggling with cs_bar=0. Consider fixing DUT condition to & ~cs_bar if this is the case.");
            // end
        // join_any

        // if (uo_out[6] == 0 || uo_out[6] == 1) begin
            // while (bit_idx >= 0) begin
                // @(negedge uo_out[6]);
                // ui_in[5] = spi_tx_data[bit_idx];
                // bit_idx--;
            // end

            // fork
                // begin
                    // wait(uo_out[4] == 1);
                    // $display("SPI RX valid asserted with cs_bar=0.");
                // end
                // begin
                    // #10000;
                    // $display("Timeout: rx_valid not asserted with cs_bar=0.");
                // end
            // join_any
        // end

        // @(posedge clk);
        // uio_in[1] = 1;
        // #20;
        // uio_in[1] = 0;

        // fork
            // begin
                // wait(uo_out[6] == 0);
                // $display("SCLK started for TX with cs_bar=0.");
            // end
            // begin
                // #2000;
                // $display("Timeout: SCLK did not start for TX with cs_bar=0.");
            // end
        // join_any

        // spi_rx_received = 0;
        // bit_idx = 0;
        // while (bit_idx < 16) begin
            // @(posedge uo_out[6]);
            // spi_rx_received = {spi_rx_received[14:0], uo_out[1]};
            // bit_idx++;
        // end
        // wait(uo_out[5] == 1);
        // #20;

        // if (spi_rx_received == spi_tx_data)
            // $display("SPI test with cs_bar=0 passed: sent %h, received %h (suggests DUT bug in start condition; should be & ~cs_bar)", spi_tx_data, spi_rx_received);
        // else
            // $display("SPI test with cs_bar=0 failed: sent %h, received %h", spi_tx_data, spi_rx_received);

        // #1000;
        // $finish;
    end

endmodule