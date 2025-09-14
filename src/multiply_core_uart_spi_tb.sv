`timescale 1ns/1ns
module tb_multiply_core_uart_spi;
  // Declare DUT interface signals
  logic clk, reset;
  logic communication_sel;       // 1: UART, 0: SPI
  logic loopback;                // bypass the core multiplier if set to 1
  logic [1:0] freq_control;
  logic uart_rx;
  logic cs_bar;
  logic mosi;
  logic mul_enable;
  logic uart_tx;
  logic sclk, miso;
  logic frames_received;
  
  // Instantiate the DUT
  multiply_core_uart_spi dut (
    .clk(clk),
    .reset(reset),
    .communication_sel(communication_sel),
    .loopback(loopback),
    .freq_control(freq_control),
    .uart_rx(uart_rx),
    .cs_bar(cs_bar),
    .sclk(sclk),
    .mosi(mosi),
    .mul_enable(mul_enable),
    .uart_tx(uart_tx),
    .miso(miso),
    .frames_received(frames_received)
  );
  
  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;
  
  // Main stimulus
  initial begin
    reset = 1; communication_sel = 1; freq_control = 2'b00;
    uart_rx = 0; cs_bar = 1; mosi = 0; mul_enable = 0;
    #15;
    reset = 0;
    
    // UART mode test
    communication_sel = 1;
    mul_enable = 1;
    // Simulate receiving two frames via UART
    uart_rx = 1'b1; #10; uart_rx = 1'b0; #10; // Frame 1
    uart_rx = 1'b1; #10; uart_rx = 1'b0; #10; // Frame 2
    #100; // Wait for FSM transitions
    
    // SPI mode test
    communication_sel = 0;
    cs_bar = 1; mosi = 1;
    mul_enable = 1;
    #10; cs_bar = 0; #10; // SPI transaction
    cs_bar = 1; mosi = 0;
    #100; // Wait for FSM transitions
    
    // Check output/status
    $display("UART_TX: %b, MISO: %b, FRAMES_RECEIVED: %b", uart_tx, miso, frames_received);
    $finish;
  end
endmodule
