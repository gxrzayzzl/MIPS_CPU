module Forwarding(RegWrite_MEM,RegWrAddr_MEM,RsAddr_EX,RtAddr_EX,RegWrite_WB,RegWrAddr_WB,
                      ForwardA,ForwardB);
	input RegWrite_MEM,RegWrite_WB;
	input [4:0]RegWrAddr_MEM,RsAddr_EX,RtAddr_EX,RegWrAddr_WB;
	output [1:0]ForwardA,ForwardB;
	
	assign ForwardA=(RegWrite_MEM&&RegWrAddr_MEM!=0&&(RegWrAddr_MEM==RsAddr_EX))?2'b10:
					(RegWrite_WB&&RegWrAddr_WB!=0&&(RegWrAddr_WB==RsAddr_EX)&&((RegWrAddr_MEM!=RsAddr_EX)||~RegWrite_MEM))?2'b01:2'b00;
	assign ForwardB=(RegWrite_MEM&&RegWrAddr_MEM!=0&&(RegWrAddr_MEM==RtAddr_EX))?2'b10:
					(RegWrite_WB&&RegWrAddr_WB!=0&&(RegWrAddr_WB==RtAddr_EX)&&((RegWrAddr_MEM!=RtAddr_EX)||~RegWrite_MEM))?2'b01:2'b00;
					
endmodule