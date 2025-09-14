// `timescale 1ns/1ns

module tb_spi_master_slave_v3_clk_crtl_loopback;

    logic clk;
    logic reset;
    logic slave_rx_start;
    logic slave_tx_start;
    logic loopback;
    // logic [15:0] miso_reg_data;  // Not driven directly
    logic mosi;
    logic [1:0] freq_control;
    logic cs_bar;
    logic sclk;
    logic miso;
    // logic [15:0] mosi_reg_data;  // Not checked directly
    logic rx_valid;
    logic tx_done;

    spi_master_slave_v3_clk_crtl dut (
        .clk,
        .reset,
        .slave_rx_start,
        .slave_tx_start,
        .loopback,
        // .miso_reg_data,
        .mosi,
        .freq_control,
        .cs_bar,
        .sclk,
        .miso,
        // .mosi_reg_data,
        .rx_valid,
        .tx_done
    );

    always #10 clk = ~clk;  // 100 MHz clock

    logic [15:0] tx_data;
    logic [15:0] rx_received;
    integer bit_idx;

    initial begin
        clk = 0;
        reset = 0;
        slave_rx_start = 0;
        slave_tx_start = 0;
        loopback = 1;
        mosi = 0;
        freq_control = 2'b01;  // CLK_DIV=0 for fastest clock
        cs_bar = 1;  // Required for start condition (& cs_bar)
        #20;
        reset = 1;
        #20;

        // Test 1: Serial TX+RX (send data on mosi, expect same on miso due to bypass)
        $display("Starting Serial TX+RX test...");
        tx_data = 16'h55AA;
        slave_rx_start = 1;
        slave_tx_start = 1;
        #20;
        slave_rx_start = 0;
        slave_tx_start = 0;

        // Drive mosi serially (MSB first)
        bit_idx = 15;
        mosi = tx_data[bit_idx];  // Set first bit immediately
        bit_idx--;
        while (bit_idx >= 0) begin
            @(negedge sclk);  // Drive on negedge (CPHA=0, master samples on posedge)
            mosi = tx_data[bit_idx];
            bit_idx--;
        end

        // Collect miso serially (sampled on posedge sclk)
        rx_received = 0;
        bit_idx = 0;
        wait(sclk == 1);  // Synchronize to start of SCLK burst
        while (bit_idx < 16) begin
            @(posedge sclk);  // Sample on posedge
            rx_received = {rx_received[14:0], miso};
            bit_idx++;
        end
        wait(tx_done && rx_valid);
        #20;
        if (rx_received == tx_data)
            $display("Serial TX+RX test passed: sent %h on mosi, received %h on miso", tx_data, rx_received);
        else
            $display("Serial TX+RX test failed: sent %h on mosi, received %h on miso", tx_data, rx_received);

        // Wait for state to return to IDLE
        #200;

        // Test 2: Serial TX+RX with different data
        $display("Starting Serial TX+RX test with different data...");
        tx_data = 16'hA55A;
        slave_rx_start = 1;
        slave_tx_start = 1;
        #20;
        slave_rx_start = 0;
        slave_tx_start = 0;

        // Drive mosi serially
        bit_idx = 15;
        mosi = tx_data[bit_idx];
        bit_idx--;
        while (bit_idx >= 0) begin
            @(negedge sclk);
            mosi = tx_data[bit_idx];
            bit_idx--;
        end

        // Collect miso serially
        rx_received = 0;
        bit_idx = 0;
        wait(sclk == 1);
        while (bit_idx < 16) begin
            @(posedge sclk);
            rx_received = {rx_received[14:0], miso};
            bit_idx++;
        end
        wait(tx_done && rx_valid);
        #20;
        if (rx_received == tx_data)
            $display("Serial TX+RX test passed: sent %h on mosi, received %h on miso", tx_data, rx_received);
        else
            $display("Serial TX+RX test failed: sent %h on mosi, received %h on miso", tx_data, rx_received);

        // Wait for state to return to IDLE
        #200;

        // Test 3: Serial TX+RX with slower clock
        $display("Starting Serial TX+RX test with freq_control=2'b11 (1MHz)...");
        freq_control = 2'b11;  // CLK_DIV=24
        #200;
        tx_data = 16'h1234;
        slave_rx_start = 1;
        slave_tx_start = 1;
        #20;
        slave_rx_start = 0;
        slave_tx_start = 0;

        // Drive mosi serially
        bit_idx = 15;
        mosi = tx_data[bit_idx];
        bit_idx--;
        while (bit_idx >= 0) begin
            @(negedge sclk);
            mosi = tx_data[bit_idx];
            bit_idx--;
        end

        // Collect miso serially
        rx_received = 0;
        bit_idx = 0;
        wait(sclk == 1);
        while (bit_idx < 16) begin
            @(posedge sclk);
            rx_received = {rx_received[14:0], miso};
            bit_idx++;
        end
        wait(tx_done && rx_valid);
        #20;
        if (rx_received == tx_data)
            $display("Serial TX+RX test (slow clock) passed: sent %h on mosi, received %h on miso", tx_data, rx_received);
        else
            $display("Serial TX+RX test (slow clock) failed: sent %h on mosi, received %h on miso", tx_data, rx_received);

        #200;
        $finish;
    end

endmodule