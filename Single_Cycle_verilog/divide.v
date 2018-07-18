
module divide(sys_clk,clk);
	
	input sys_clk;
	reg [24:0] count;
	output reg clk;
	parameter gate=25'b1_1111_1010_1111_0000_1000_0000;
	parameter gate_for_sim = 25'b0_0000_0000_0000_0000_0000_0100;
	initial begin clk<=1'b0;count<=25'b0_0000_0000_0000_0000_0000_0000;end
	always@(posedge sys_clk)
	begin
		if(count==gate_for_sim)
		begin
			count<=25'b0_0000_0000_0000_0000_0000_0000;
			clk=~clk;
		end else count<=count+26'b0_0000_0000_0000_0000_0000_0001;
	end
	
endmodule