
module Control(OpCode, Funct, IRQ, PC_31,
	PCSrc, RegWrite, RegDst, 
	MemRead, MemWrite, MemtoReg, 
	ALUSrc1, ALUSrc2, ExtOp, LuOp, Sign, ALUFun,
	BranchType,JumpType);
	input [5:0] OpCode;
	input [5:0] Funct;
	input IRQ;
	input PC_31;
	output [2:0] PCSrc;
	output RegWrite;
	output [1:0] RegDst;
	output MemRead;
	output MemWrite;
	output [1:0] MemtoReg;
	output ALUSrc1;
	output ALUSrc2;
	output ExtOp;
	output LuOp;
	output Sign;
	output reg [5:0] ALUFun;
	output BranchType;
	output JumpType;
	
	assign PCSrc=(IRQ&&~PC_31)?3'b100:
		((OpCode==6'h00&&(Funct==6'h00||(Funct>=6'h20&&Funct<=6'h27)||Funct==6'h2a||Funct==6'h02||Funct==6'h03))||
		(OpCode==6'h23||OpCode==6'h2b||OpCode==6'h08||OpCode==6'h09||OpCode==6'h0a||OpCode==6'h0b||OpCode==6'h0c||OpCode==6'h0f))?3'b000:
		(OpCode==6'h01||(OpCode>=6'h04&&OpCode<=6'h07))?3'b001:
		(OpCode==6'h02||OpCode==6'h03)?3'b010:
		(OpCode==6'h00&&(Funct==6'h08||Funct==6'h09))?3'b011:3'b101;
		
	assign RegWrite=(IRQ&&~PC_31)?1:
		(OpCode==6'h2b||OpCode==6'h01||(OpCode>=6'h04&&OpCode<=6'h07)||OpCode==6'h11||OpCode==6'h02||(OpCode==6'h00&&Funct==6'h08))?0:1;

	assign RegDst=(IRQ&&~PC_31)?2'b11:
		(OpCode==6'h23||OpCode==6'h0f||OpCode==6'h08||OpCode==6'h09||OpCode==6'h0a||OpCode==6'h0b||OpCode==6'h0c)?2'b00:
		(OpCode==6'h00&&(Funct==6'h00||Funct==6'h02||Funct==6'h03||(Funct>=6'h20&&Funct<=6'h27)||Funct==6'h2a))?2'b01:
		(OpCode==6'h03||(OpCode==6'h00&&Funct==6'h09))?2'b10:2'b11;

	assign MemRead=(IRQ&&~PC_31)?0:(OpCode==6'h23)?1:0;
	
	assign MemWrite=(IRQ&&~PC_31)?0:(OpCode==6'h2b)?1:0;

	assign MemtoReg=(IRQ&&~PC_31)?2'b10:
		(OpCode==6'h23)?2'b01:
		(OpCode==6'h03||OpCode==6'h00&&(Funct==6'h09))?2'b10:
		(OpCode==6'h00&&(Funct==6'h00||Funct==6'h02||Funct==6'h03||Funct==6'h22||(Funct>=6'h20&&Funct<=6'h27)||Funct==6'h2a)||
		(OpCode==6'h08||OpCode==6'h09||OpCode==6'h0a||OpCode==6'h0b||OpCode==6'h0c||OpCode==6'h0f))?2'b00:2'b10;

	assign ALUSrc1=(OpCode==6'h00&&(Funct==6'h00||Funct==6'h02||Funct==6'h03))?1:0;

	assign ALUSrc2=(OpCode==6'h00||OpCode==6'h01||(OpCode>=6'h04&&OpCode<=6'h07))?0:1;

	assign ExtOp=(OpCode==6'h0c)?0:1;

	assign LuOp=(OpCode==6'h0f)? 1:0;

	assign Sign=(OpCode==6'h09||OpCode==6'h0b||OpCode==6'h00&&(Funct==6'h21|Funct==6'h23))?0:1;
	
	assign BranchType=(IRQ&&~PC_31)?0:(OpCode==6'h01||(OpCode>=6'h04&&OpCode<=6'h07))?1:0;
	
	assign JumpType=(IRQ&&~PC_31)?0:((OpCode==6'h02||OpCode==6'h03)||(OpCode==6'h00&&(Funct==6'h08||Funct==6'h09)))?1:0;
	
	parameter aluADD = 6'b000000;
	parameter aluSUB = 6'b000001;
	parameter aluAND = 6'b011000;
	parameter aluOR  = 6'b011110;
	parameter aluXOR = 6'b010110;
	parameter aluNOR = 6'b010001;
	parameter aluA   = 6'b011010;
	parameter aluSLL = 6'b100000;
	parameter aluSRL = 6'b100001;
	parameter aluSRA = 6'b100011;
	parameter aluEQ  = 6'b110011;
	parameter aluNEQ = 6'b110001;
	parameter aluLT  = 6'b110101;
	parameter aluLEZ = 6'b111101;
	parameter aluLTZ = 6'b111011;
	parameter aluGTZ = 6'b111111;
	
	reg [5:0] aluFunct;
	always @(*)
		case (Funct[5:0])
			6'b00_0000: aluFunct <= aluSLL;
			6'b00_0010: aluFunct <= aluSRL;
			6'b00_0011: aluFunct <= aluSRA;
			6'b10_0000: aluFunct <= aluADD;
			6'b10_0001: aluFunct <= aluADD;
			6'b10_0010: aluFunct <= aluSUB;
			6'b10_0011: aluFunct <= aluSUB;
			6'b10_0100: aluFunct <= aluAND;
			6'b10_0101: aluFunct <= aluOR;
			6'b10_0110: aluFunct <= aluXOR;
			6'b10_0111: aluFunct <= aluNOR;
			6'b10_1010: aluFunct <= aluLT;
			default: 	aluFunct <= aluADD;
		endcase
	
	always @(*)
		case (OpCode[5:0])
			6'b00_0000: ALUFun <= aluFunct;
			6'b00_0001: ALUFun <= aluGTZ;
			6'b00_0100: ALUFun <= aluEQ;
			6'b00_0101: ALUFun <= aluNEQ;
			6'b00_0110: ALUFun <= aluLEZ;
			6'b00_0111: ALUFun <= aluLTZ;
			6'b00_1000: ALUFun <= aluADD;
			6'b00_1001: ALUFun <= aluADD;
			6'b00_1010: ALUFun <= aluLT;
			6'b00_1011: ALUFun <= aluLT;
			6'b00_1100: ALUFun <= aluAND;
			6'b00_1111: ALUFun <= aluADD;
			default:    ALUFun <= aluADD;
		endcase
	
endmodule