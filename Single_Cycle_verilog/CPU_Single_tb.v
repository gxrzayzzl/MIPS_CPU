`timescale 1ns / 1ps


module CPU_tb();

	reg sys_clk;
	reg reset;
	reg UART_RX;
	wire UART_TX;
	wire [7:0] LED;
	wire [17:0] TUBE;
	wire [7:0] TEST_LED;
	
	initial
	begin
		sys_clk<=1;
		reset<=0;
		#20 reset<=1;
		#50 reset<=0;
	end

	always @(*)
	begin
		#5 sys_clk<=~sys_clk;
	end
	
	initial
	begin
		UART_RX=1;
		#200000 UART_RX=0;
		#416666 UART_RX=1;
		#104166 UART_RX=0;
		#420832 UART_RX=1;
		#208332 UART_RX=0;
		#520832 UART_RX=1;
		#104166 UART_RX=0;
		#366666 UART_RX=1;
	end
	
	CPU cpu(.sys_clk(sys_clk),.reset(reset),.UART_RX(UART_RX),.UART_TX(UART_TX),.LED(LED),.TUBE(TUBE),.TEST_LED(TEST_LED));
	
endmodule