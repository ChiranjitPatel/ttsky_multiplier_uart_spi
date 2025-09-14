//-----------------------------------------------------------------------------------------------------------------------------------------------------
// Company:			NUS
// Engineer:		Vivek Adi (email : vivek.adishesha@u.nus.edu ) 
//
// Creation Date:	(c) 2024 NUS
// Design Name:		System Verilog Logic of UART-Protocol Transmitter
// Module Name:		uart_tx	- Behavioral
// Project Name:	MRAM Statistical Data Collection
// Target Devices:	AMD Zedboard ZYNQ (ZED) - Xilinx XC7Z020-1CSG484CES EPP
// Tool Versions:	AMD Vivado 2024.1
// Description:		
// Dependencies:	
// Revision:		Revision 0.01 - File Created
// Comments:
//-----------------------------------------------------------------------------------------------------------------------------------------------------			
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// `timescale 1ns / 1ps

module uart_tx 
	// # (	parameter [23:0] baud_rate = 24'd4000000,
		// parameter [27:0]clock_freq = 28'd100000000 )
	  ( uart_clock, uart_reset, uart_start, uart_d_in, freq_control,
		uart_d_out, uart_tx_ready);
		
	input	logic			uart_clock;
	input	logic			uart_reset;
	input	logic			uart_start;
	input	logic	[7:0]	uart_d_in;
	input	logic	[1:0]	freq_control;
	output	logic			uart_d_out;
	output	logic			uart_tx_ready;
	
	// localparam [19:0]	pulse_duration			=	clock_freq / baud_rate /2;	// Delay for each bit TX, divide by 2 for the one cycle time
	// localparam [23:0]	pulse_duration			=	24'd10416; //clock_freq / baud_rate;	// Delay for each bit TX, No need to divide by 2.
	localparam [3:0]	start_data_stop_width	=	4'd10;
	
	logic transmit_complete;
	logic tx_reg_ready;
	logic [3:0]		bit_count;
	logic [23:0] 	clk_count;
	logic [1:0] 	edge_detect_reg;
	logic [9:0] 	data_shift_reg;
	logic [23:0] pulse_duration;
	// logic [23:0] baud_rate;
	
	typedef enum logic[1:0] {Init, Load_Data, Shift_Data} state_machine;
	state_machine state;

//-----------------------------------------------------------------------------------------------------------------------------------------------------	

	always_comb begin
		uart_tx_ready = transmit_complete & tx_reg_ready;
		uart_d_out	=	data_shift_reg[0];
		
		if (freq_control == 2'b00) begin
			// baud_rate = 24'd9600;
			pulse_duration = 24'd5208;
		end
		else if (freq_control == 2'b01) begin
			// baud_rate = 24'd115000;
			pulse_duration = 24'd434;
		end
		else if (freq_control == 2'b10) begin
			// baud_rate = 24'd1000000;
			pulse_duration = 24'd50;
		end
		else begin
			// baud_rate = 24'd4000000;
			pulse_duration = 24'd12;
		end
	end

	
	always_ff @(posedge uart_clock, negedge uart_reset) begin
		if(!uart_reset) begin
			state 				<= Init;
			transmit_complete	<= 1'b1;
			tx_reg_ready		<= 1'b1;
			bit_count			<= 4'b0;
			edge_detect_reg		<= 2'b0;
			data_shift_reg 		<= 10'b1111111111;	// To keep the Tx line high for the Rx to detect start bit
			clk_count 			<= 24'b0;
		end
		
		else begin
			case(state) 
				Init		:	begin
									// Trasmission complete
									transmit_complete <= 1'b1;
									tx_reg_ready <= 1'b1;
										
									// Edge Detection and Begin Transmit
									edge_detect_reg[0] <= uart_start;
									edge_detect_reg[1] <= ~edge_detect_reg[0];
									if ((edge_detect_reg[0] & edge_detect_reg[1]) == 1) begin
										transmit_complete <= 1'b0;
										tx_reg_ready <= 1'b0;
										state <= Load_Data;
									end
									else 
										state <= Init;
								end
								
				Load_Data	:	begin
									// Loading the Start-Data-Stop bits to a register
									data_shift_reg <= {1'b1, uart_d_in, 1'b0};
									state <= Shift_Data;
								end
									
				Shift_Data	:	begin
									// If count = pulse duration shift 1-bit into the register for TX
									if (clk_count == pulse_duration) begin
										clk_count <= 24'b0;
										data_shift_reg <= {1'b1, data_shift_reg[9:1]};
										bit_count <= bit_count + 1'b1;
									end
									else begin
										clk_count <=  clk_count + 1'b1;
									end
									
									// If bit count = total bits in register, completed TX, ready for next
									if (bit_count == start_data_stop_width) begin
										state <= Init;
										clk_count <= 24'b0;
										bit_count <= 4'b0;
									end
									else 
										state <= Shift_Data;
								end
								
				default		:	state <= Init;
			endcase
		end
	end

endmodule
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++								