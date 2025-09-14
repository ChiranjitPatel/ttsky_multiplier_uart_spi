module tb_spi_master_slave;

    logic clk;
    logic reset;
    logic slave_rx_start;
    logic slave_tx_start;
    logic [15:0] miso_reg_data;
    logic mosi;
    logic [1:0] freq_control;
    logic cs_bar;
    logic sclk;
    logic miso;
    logic [15:0] mosi_reg_data;
    logic rx_valid;
    logic tx_done;

    spi_master_slave dut (
        .clk,
        .reset,
        .slave_rx_start,
        .slave_tx_start,
        .miso_reg_data,
        .mosi,
        .freq_control,
        .cs_bar,
        .sclk,
        .miso,
        .mosi_reg_data,
        .rx_valid,
        .tx_done
    );

    always #5 clk = ~clk;

    logic [15:0] tx_data;
    logic [15:0] rx_expected;
    logic [15:0] tx_received;
    integer bit_idx;

    initial begin
        clk = 0;
        reset = 0;
        slave_rx_start = 0;
        slave_tx_start = 0;
        miso_reg_data = 0;
        mosi = 0;
        freq_control = 2'b01;  // CLK_DIV=0 for fastest clock
        cs_bar = 1;  // Set to 1 as required by the start condition (& cs_bar)
        #10;
        reset = 1;
        #20;

        // Test 1: TX only
        $display("Starting TX-only test...");
        tx_data = 16'h55AA;
        miso_reg_data = tx_data;
        slave_tx_start = 1;
        #10;
        slave_tx_start = 0;

        // Collect transmitted bits on miso (sampled on posedge sclk)
        tx_received = 0;
        bit_idx = 0;
        wait(sclk == 1);  // Ensure we start synchronized
        while (bit_idx < 16) begin
            @(negedge sclk);  // Data driven on negedge
            @(posedge sclk);  // Sample on posedge
            tx_received = {tx_received[14:0], miso};
            bit_idx++;
        end
        wait(tx_done);
        #10;
        if (tx_received == tx_data)
            $display("TX-only test passed: sent %h, collected on miso %h", tx_data, tx_received);
        else
            $display("TX-only test failed: sent %h, collected on miso %h", tx_data, tx_received);

        // Wait for state to return to IDLE
        #200;

        // Test 2: RX only
        $display("Starting RX-only test...");
        rx_expected = 16'hA55A;
        slave_rx_start = 1;
        #10;
        slave_rx_start = 0;

        // Simulate slave driving mosi (MISO from slave perspective) on negedge sclk
        bit_idx = 15;  // MSB first
        @(negedge sclk);  // First negedge after start
        mosi = rx_expected[bit_idx];
        bit_idx--;
        while (bit_idx >= 0) begin
            @(negedge sclk);
            mosi = rx_expected[bit_idx];
            bit_idx--;
        end
        wait(rx_valid);
        #10;
        if (mosi_reg_data == rx_expected)
            $display("RX-only test passed: expected %h, received %h", rx_expected, mosi_reg_data);
        else
            $display("RX-only test failed: expected %h, received %h", rx_expected, mosi_reg_data);

        // Wait for state to return to IDLE
        #200;

        // Test 3: TX and RX simultaneously
        $display("Starting TX+RX test...");
        tx_data = 16'h1234;
        rx_expected = 16'h5678;
        miso_reg_data = tx_data;
        slave_tx_start = 1;
        slave_rx_start = 1;
        #10;
        slave_tx_start = 0;
        slave_rx_start = 0;

        // Simulate slave for RX: drive mosi on negedge sclk
        bit_idx = 15;
        @(negedge sclk);
        mosi = rx_expected[bit_idx];
        bit_idx--;
        while (bit_idx >= 0) begin
            @(negedge sclk);
            mosi = rx_expected[bit_idx];
            bit_idx--;
        end

        // Collect for TX verification: sample miso on posedge sclk
        tx_received = 0;
        bit_idx = 0;
        while (bit_idx < 16) begin
            @(negedge sclk);
            @(posedge sclk);
            tx_received = {tx_received[14:0], miso};
            bit_idx++;
        end
        wait(tx_done && rx_valid);
        #10;
        if (tx_received == tx_data && mosi_reg_data == rx_expected)
            $display("TX+RX test passed: TX sent/collected %h/%h, RX expected/received %h/%h", tx_data, tx_received, rx_expected, mosi_reg_data);
        else
            $display("TX+RX test failed: TX sent/collected %h/%h, RX expected/received %h/%h", tx_data, tx_received, rx_expected, mosi_reg_data);

        // Additional test with different frequency
        $display("Starting TX test with freq_control=2'b11 (1MHz)...");
        freq_control = 2'b11;  // CLK_DIV=24
        #100;
        tx_data = 16'hABCD;
        miso_reg_data = tx_data;
        slave_tx_start = 1;
        #10;
        slave_tx_start = 0;

        tx_received = 0;
        bit_idx = 0;
        while (bit_idx < 16) begin
            @(negedge sclk);
            @(posedge sclk);
            tx_received = {tx_received[14:0], miso};
            bit_idx++;
        end
        wait(tx_done);
        #10;
        if (tx_received == tx_data)
            $display("TX test with slow clock passed: sent %h, collected %h", tx_data, tx_received);
        else
            $display("TX test with slow clock failed: sent %h, collected %h", tx_data, tx_received);

        #200;
        $finish;
    end

endmodule