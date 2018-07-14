
module divide(sys_clk,clk);
	
	input sys_clk;
	output reg clk;
	initial clk<=1'b0;
	always@(posedge sys_clk)clk<=~clk;
	
endmodule