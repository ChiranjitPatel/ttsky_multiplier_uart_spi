`timescale 1ns/1ns

module multiply_core_uart_spi 
	(
	clk,
	reset,
	communication_sel, 
	loopback, 
	freq_control,
	uart_rx,
	cs_bar,
	sclk,
	mosi,
	mul_enable,
	uart_tx,
	miso,
	frames_received
	);

	input logic clk;
	input logic reset;
	input logic communication_sel;
	input logic loopback;
	input logic [1:0] freq_control;
	input logic uart_rx;
	input logic cs_bar;
	input logic mosi;
	input logic mul_enable;
	output logic uart_tx;
	output logic sclk;
	output logic miso;
	output logic frames_received;

	localparam integer NUM_FRAMES = 2;
	localparam integer DELAY_TIME = 100;
	localparam integer UART_TX_DELAY = 100000;
	localparam integer UART_TX_DELAY_BITS = $clog2(UART_TX_DELAY);

	logic [15:0] mul_ip_BA; // B is [15:8], A is [7:0]
	logic [15:0] mul_op_prod; // 16-bit output of multipler
	logic [15:0] mosi_reg_data; // 16-bit mosi reg
	logic [15:0] miso_reg_data; // 16-bit miso reg
	logic [7:0] rx_frames [1:0];
	
	// UART
    logic       uart_tx_start;
    logic [7:0] uart_transmit_data;
    logic [7:0] uart_received_data;
    logic       uart_rx_valid;
    logic       uart_tx_ready;
	logic       uart_rx_valid_edge;
	logic 		uart_tx_ready_edge;
	logic [UART_TX_DELAY_BITS-1:0]  uart_tx_delay_count;
	logic 		rx_valid_edge;
	logic 		slave_rx_start;
	logic 		slave_tx_start;
	logic 		tx_done_edge;
	logic		mul_start;
	logic		mul_ready;
	
	
	logic [1:0] rx_frames_count;
	logic [1:0] tx_frames_count;
	logic [7:0] delay_count;
	
	typedef enum logic[2:0] {Init, Rx_Frames, Delay, Multiply, Tx_Data, Tx_Delay, Finish} state_machine;
    state_machine state;

	// Instantiate the uart_rx_tx module
    uart_rx_tx uart_uut (
        .clk_int(clk),
        .uart_reset(reset),
        // .uart_transmit_data(uart_transmit_data),
        .uart_rx_d_in(uart_rx),
        .loopback(loopback),
        .uart_tx_start(uart_tx_start),
		.freq_control(freq_control),
        .uart_tx_d_out(uart_tx),
        // .uart_received_data(uart_received_data),
        .uart_rx_valid(uart_rx_valid),
        .uart_tx_ready(uart_tx_ready)
    );

	// spi_slave spi_uut (
		// .clk(clk),           
		// .reset(reset),
		// .spi_start(spi_start),
		// .miso_reg_data(miso_reg_data),
		// .mosi(mosi),
		// .cs_bar(cs_bar),       
		// .sclk(sclk),
		// .miso(miso),	
		// .mosi_reg_data(mosi_reg_data),
		// .rx_valid(rx_valid),
		// .tx_done(tx_done)
	// );
	
	spi_master_slave_v3_clk_crtl dut (
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
	
	i8bit_mul_interface multiplier_interface_uut (
		.clk(clk),
		.reset(reset),
		.mul_start(mul_start), 
		.mul_ip_BA(mul_ip_BA), 
		.mul_op_prod(mul_op_prod),
		.mul_ready(mul_ready)
	);
	
	always_comb begin
		//direct mapping possible?
		mul_ip_BA[7:0] = rx_frames[0]; 
		mul_ip_BA[15:8] = rx_frames[1]; 
	end
	
	always_ff @(posedge clk or negedge reset) begin
	
		if (~reset) begin
			frames_received <= 1'b0;
			uart_rx_valid_edge <= 1'b0;
			rx_frames_count <= 5'b0;
			tx_frames_count <= 0;
			rx_frames <= '{NUM_FRAMES{8'h00}};
			delay_count <= 8'b0;
			slave_rx_start <= 1'b0;
			rx_valid_edge <= rx_valid;
			mul_start <= 1'b0;
			miso_reg_data <= 16'b0;
			uart_tx_start <= 1'b0;
			uart_transmit_data <= 8'b0;
			uart_tx_ready_edge <= 0;
			uart_tx_delay_count <= 0;
			slave_tx_start <= 1'b0;
			tx_done_edge <= 1'b0;
			state <= Init;
		end
	
		else begin
			case(state)
				Init		:	begin
									if (mul_enable) 
										state <= Rx_Frames;
									else 
										state <= Init;
								end
		
				Rx_Frames   :	begin
									if (communication_sel) begin
										uart_rx_valid_edge <= uart_rx_valid;
										if (~uart_rx_valid_edge & uart_rx_valid) begin
											rx_frames[rx_frames_count] <= uart_received_data;
											if (rx_frames_count == (NUM_FRAMES-1)) begin
												rx_frames_count <= 0;
												frames_received <= 1'b1;
												state <= Delay;
											end
											else
												rx_frames_count <= rx_frames_count + 1'b1;
										end
										else
											state <= Rx_Frames;
									end
									
									else begin
										if (cs_bar) begin
											slave_rx_start <= 1'b1;
											rx_valid_edge <= rx_valid;
											if (~rx_valid_edge & rx_valid) begin
												slave_rx_start <= 1'b0;
												rx_frames[0] <= mosi_reg_data[7:0];
												rx_frames[1] <= mosi_reg_data[15:8];
												frames_received <= 1'b1;
												state <= Delay;
											end
											else 
												state <= Rx_Frames;
										end
										else
											state <= Rx_Frames;
									end
								end
								
							
				Delay   	:	begin
									if (delay_count == DELAY_TIME) begin
										delay_count <= 8'b0;
										mul_start <= 1'b1;
										state <= Multiply;
									end
									else
										delay_count <= delay_count + 1'b1;
								end
							
				Multiply    :	begin
									if (mul_ready) begin
										miso_reg_data <= mul_op_prod;
										mul_start <= 1'b0;
										state <= Tx_Data;
									end
									else
										state <= Multiply;
								end
	
				Tx_Data		:	begin
									if (communication_sel) begin
										uart_tx_ready_edge <= uart_tx_ready;
										if (uart_tx_ready) begin
											if ((~uart_tx_ready_edge & uart_tx_ready) == 1) begin
												uart_tx_start <= 1'b0;
												uart_transmit_data <= 0;
												if (tx_frames_count == NUM_FRAMES/2) begin
													tx_frames_count <= 0;
													state <= Finish;
												end
												else begin
													state <= Tx_Delay;
												end
											end
											
											else begin
												uart_tx_start <= 1'b1;
												uart_transmit_data <= mul_op_prod[tx_frames_count * 8 +: 8];
											end
										end
										
										else begin
											if ((uart_tx_ready_edge & ~uart_tx_ready) == 1) begin
												uart_tx_start <= 1'b0;
												tx_frames_count <= tx_frames_count + 1'b1;
											end
											else
												state <= Tx_Data;
										end
									end
									
									else begin
										if (cs_bar) begin
											slave_tx_start <= 1'b1;
											miso_reg_data <= mul_op_prod;
											tx_done_edge <= tx_done;
											if (~tx_done_edge & tx_done) begin
												slave_tx_start <= 1'b0;
												state <= Tx_Delay;
											end
											else
												state <= Tx_Data;
										end
										else 
											state <= Tx_Data;
									end
								end
				
				Tx_Delay	:	begin
									if (uart_tx_delay_count == UART_TX_DELAY) begin
										uart_tx_delay_count <= 0;
										state <= Tx_Data;
									end
									else
										uart_tx_delay_count <= uart_tx_delay_count + 1'b1;
								end
	
				Finish		:	state <= Init;
				
				default		:	state <= Init;
	
				
			endcase
		end
	end
endmodule

