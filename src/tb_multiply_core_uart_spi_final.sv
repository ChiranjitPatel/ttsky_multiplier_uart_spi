`timescale 1ns/1ns

module tb_multiply_core_uart_spi;

    logic clk;
    logic reset;
    logic communication_sel;
    logic loopback;
    logic [1:0] freq_control;
    logic uart_rx;
    logic cs_bar;
    logic sclk;
    logic mosi;
    logic mul_enable;
    logic uart_tx;
    logic miso;
    logic frames_received;

    multiply_core_uart_spi dut (
        .clk,
        .reset,
        .communication_sel,
        .loopback,
        .freq_control,
        .uart_rx,
        .cs_bar,
        .sclk,
        .mosi,
        .mul_enable,
        .uart_tx,
        .miso,
        .frames_received
    );

    always #20 clk = ~clk;  // 100 MHz clock

    logic [15:0] rx_expected;
    logic [15:0] tx_received;
    logic [15:0] expected_prod;
    integer bit_idx;

    initial begin
        clk = 0;
        reset = 0;
        loopback = 0;  // SPI mode
        communication_sel = 0;  // SPI mode
        freq_control = 2'b01;   // Fastest clock
        uart_rx = 1;            // Idle
        cs_bar = 1;             // Required for start
        mosi = 0;
        mul_enable = 0;
        #20;
        reset = 1;
        #20;

        // SPI Test
        $display("Starting SPI RX-TX test...");
        mul_enable = 1;
        #20;

        // RX phase: Drive mosi with input data (B A, MSB first)
        rx_expected = 16'hA55A;  // Example: B=0xA5 (165), A=0x5A (90)
        bit_idx = 15;
        mosi = rx_expected[bit_idx];  // Set first bit immediately
        bit_idx--;
        while (bit_idx >= 0) begin
            @(negedge sclk);
            mosi = rx_expected[bit_idx];
            bit_idx--;
        end

        // Wait for frames received
        wait(frames_received);
        #20;
        $display("Frames received: %h %h", dut.rx_frames[1], dut.rx_frames[0]);

        // Delay phase (100 clocks at 10 ns period = 1000 ns) + buffer for multiply
        #2200;

        // TX phase: Collect product on miso
        tx_received = 0;
        bit_idx = 0;
        wait(sclk == 1);  // Synchronize to start of TX SCLK burst
        while (bit_idx < 16) begin
            @(negedge sclk);
            @(posedge sclk);
            tx_received = {tx_received[14:0], miso};
            bit_idx++;
        end
        #20;

        expected_prod = 8'h5A * 8'hA5;  // 90 * 165 = 14850 = 0x39F2
        if (tx_received == expected_prod)
            $display("SPI test passed: received product %h, expected %h", tx_received, expected_prod);
        else
            $display("SPI test failed: received product %h, expected %h", tx_received, expected_prod);

        // Wait and finish
        #200;
        // $finish;
    end

    // Optional: Additional test with different data
    // You can add more tests by resetting mul_enable=0, waiting, then repeating with new rx_expected

endmodule