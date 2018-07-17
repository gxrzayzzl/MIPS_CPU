
module divide(sys_clk,clk);
	
	input sys_clk;
	reg [3:0] count;
	output reg clk;
	parameter gate=4'b0010;
	initial begin clk<=1'b0;count<=4'b0000;end
	always@(posedge sys_clk)
	begin
		if(count==gate)
		begin
			count<=4'b0000;
			clk=~clk;
		end else count<=count+4'b0001;
	end
	
endmodule