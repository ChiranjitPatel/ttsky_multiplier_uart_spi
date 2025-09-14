// `default_nettype wire

module spi_master_slave_v3_clk_crtl (
    clk,           
    reset,
	slave_rx_start,
	slave_tx_start,
	loopback,
	// miso_reg_data,
    mosi, 	
	freq_control,
    cs_bar,       
    sclk,
	miso,	
    // mosi_reg_data,
    rx_valid,
	tx_done
);


	// I/o
	input	logic clk;           				// Internal clock
	input	logic reset;		
	input 	logic slave_rx_start;       		// rx_start spi transfer
	input 	logic slave_tx_start;       		// tx_start spi transfer
	input 	logic loopback;       		// tx_start spi transfer
	// input 	logic [15:0] miso_reg_data; 		// miso_reg_data from multiplier or internal core module
	input	logic mosi;        					// spi from external PC-master
	input   logic [1:0] freq_control;			// Clock freq selection for sclk
	input	logic cs_bar;       				// chip select, active low
	output	logic sclk;         				// spi clock - 10 MHz
	output 	logic miso;         				// spi to external PC-master
	// output	logic [15:0] mosi_reg_data;  		// mosi_reg_data to multiplier or internal core module
	output	logic rx_valid;         			// mosi_reg_data rx valid signal
	output 	logic tx_done;         				// spi tx completed flag
	

    // Param
    localparam integer WAIT_BITS = $clog2(2**6);
    localparam integer DATA_WIDTH = 16; 				// 32-bit SPI frame
    localparam integer DATA_WIDTH_BITS = $clog2(DATA_WIDTH); 				// 32-bit SPI frame
    

	integer CLK_DIV;
	
	// Reg
    logic [DATA_WIDTH-1:0] miso_reg_data;
    logic [DATA_WIDTH-1:0] mosi_reg_data;
    logic [DATA_WIDTH-1:0] rx_shift_reg;
    logic [DATA_WIDTH-1:0] tx_shift_reg;
    logic [DATA_WIDTH_BITS:0] rx_bit_cnt; 							// 6-bit to count 32 bits
    logic [DATA_WIDTH_BITS:0] tx_bit_cnt; 							// 6-bit to count 32 bits
    logic sclk_en;
    logic sclk_drive_edge;
    logic tx_ena;
    logic rx_ena;
    logic rx_state_flag;
    logic tx_state_flag;
    logic [WAIT_BITS-1:0] wait_cnt;
    logic [7:0] clk_div_cnt;
	
	// State machine
    typedef enum logic [1:0] {IDLE, TRANSFER, FINISH, WAIT_NEXT} state_t;
    state_t state;

	always_comb begin
		if (freq_control == 2'b01)      		// 25MHz  
			CLK_DIV = 0;
		else if (freq_control == 2'b10)  		// 5MHz  
			CLK_DIV = 4;
		else if (freq_control == 2'b11)   		// 1MHz  
			CLK_DIV = 24;
		else                					// 1MHz                 
			CLK_DIV = 24;
	end


    // Clock gen
    always_ff @(posedge clk or negedge reset) begin
        if (~reset) begin
            clk_div_cnt <= 0;
            sclk <= 1;
        end 
		else if (sclk_en) begin
            if (clk_div_cnt == CLK_DIV) begin
                clk_div_cnt <= 0;
                sclk <= ~sclk;
            end 
			else begin
                clk_div_cnt <= clk_div_cnt + 1'b1;
            end
        end 
		else begin
            clk_div_cnt <= 0;
            sclk <= 1;
        end
    end

	// Hardcoded connection for testing: output reg always equals input reg
	always_latch begin
		if (loopback ==1)
			mosi_reg_data = miso_reg_data;
	end
	
	// State Machine
    always_ff @(posedge clk or negedge reset) begin
        if (~reset) begin
            rx_bit_cnt <= 0;
            tx_bit_cnt <= 0;
            wait_cnt <= 0; 			
            sclk_en <= 0;
            rx_shift_reg <= 0;
            tx_shift_reg <= 0;
			tx_ena <= 0;
			rx_ena <= 0;
            rx_valid <= 0;
			tx_done <= 0;
			rx_state_flag <= 0;
			tx_state_flag <= 0;
			// mosi_reg_data <= 0;
			miso <= 0;
			
			state <= IDLE;
        end
		
		else begin
			case (state)
				IDLE: begin
					if ((slave_rx_start | slave_tx_start) & cs_bar) begin		
						sclk_en <= 1; 
						rx_bit_cnt <= 0;
						tx_bit_cnt <= 0;
						wait_cnt <= 0;
						rx_shift_reg <= {rx_shift_reg[DATA_WIDTH-2:0], mosi};
						miso_reg_data <= rx_shift_reg;
						tx_shift_reg <= miso_reg_data;
						rx_valid <= 0;
						tx_done <= 0;
						rx_state_flag <= 0;
						tx_state_flag <= 0;
						
						if (slave_tx_start) tx_ena <= 1;
						else tx_ena <= 0;
						
						if (slave_rx_start) rx_ena <= 1;
						else rx_ena <= 0;
					
						state <= TRANSFER;
					end
					else begin
						state <= IDLE;
					end
				end

				TRANSFER: begin		
					sclk_en <= 1;
					rx_valid <= 0;
					tx_done <= 0;
					
					sclk_drive_edge <= sclk;
					if ((sclk_drive_edge & ~sclk) && tx_ena) begin
						if (tx_bit_cnt == DATA_WIDTH ) begin
							tx_state_flag <= 1;
						end 
						else begin
							tx_bit_cnt <= tx_bit_cnt + 1;
							miso <= tx_shift_reg[(DATA_WIDTH - 1) - tx_bit_cnt]; // Load mosi_reg_data on the low level of sclk
							tx_state_flag <= 0;					
						end
                    end
					
					if ((~sclk_drive_edge & sclk)) begin
						rx_shift_reg <= {rx_shift_reg[DATA_WIDTH-2:0], mosi}; // Shift in mosi_reg_data from ADC	
						if (rx_bit_cnt == DATA_WIDTH) begin
							rx_state_flag <= 1;
						end
						else begin
							rx_bit_cnt <= rx_bit_cnt + 1;
							rx_state_flag <= 0;
						end
					end
					
					if (rx_state_flag || tx_state_flag) begin
						state <= FINISH;
					end
					else begin
						state <= TRANSFER;
					end	
				end

				FINISH: begin
					if (clk_div_cnt == CLK_DIV) begin
						rx_bit_cnt <= 0;
						tx_bit_cnt <= 0;
						wait_cnt <= 0;
						tx_ena <= 0;
						sclk_en <= 1;
						sclk_drive_edge <= 1'b0;
						rx_valid <= 1;
						tx_done <= 1;
						mosi_reg_data <= rx_shift_reg[DATA_WIDTH-1:0];
						miso <= 0;
						tx_shift_reg <= 0;
						rx_state_flag <= 0;
						tx_state_flag <= 0;
						
						state <= WAIT_NEXT;
					end
					else begin
						state <= FINISH;
					end
				end				

				// Add the additional wait time between the mosi_reg_data frames for better reception of mosi_reg_data to the ADC
				WAIT_NEXT: begin
					sclk_en <= 0; 
					wait_cnt <= wait_cnt + 1;
					if (wait_cnt == 2*CLK_DIV) begin
						wait_cnt <= 0;
						state <= IDLE;
					end
					else begin
						state <= WAIT_NEXT;
					end
                end
				
				default: state <= IDLE;
			endcase
		end
    end
endmodule
