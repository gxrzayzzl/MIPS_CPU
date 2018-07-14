`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Zhang Zhaoliang
// 
// Create Date: 2018/07/03 15:09:00
// Design Name: 
// Module Name: CPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CPU(
sys_clk,reset,UART_RX,UART_TX,LED,TUBE
    );
	input sys_clk,reset,UART_RX;
	output UART_TX;
	output [7:0] LED;
	output [17:0] TUBE;
	wire [7:0] switch;
	
	parameter ILLOP=32'h80000004;
	parameter XADR=32'h80000008;
	parameter START=32'h00000000;
	
	wire clk;
	wire buad;
	reg [31:0] PC;
	reg [31:0] PC_next;
	
	divide div(sys_clk,clk);
	
	wire [2:0] PCSrc;
	wire [1:0] RegDst;
	wire RegWr;
	wire ALUSrc1;
	wire ALUSrc2;
	wire [5:0]ALUFun;
	wire Sign;
	wire MemWr;
	wire MemRd;
	wire [1:0] MemToReg;
	wire ExtOp;
	wire LUOp;
	reg IRQ;
	wire if_continue;
	wire [31:0] Instruction;
	
	initial begin IRQ<=1'b0;end
	
	Control control(.OpCode(Instruction[31:26]),.Funct(Instruction[5:0]),.IRQ(IRQ),.PC_31(Instruction[31]),
					.PCSrc(PCSrc),.RegWrite(RegWr),.RegDst(RegDst),.MemRead(MemRd),.MemWrite(MemWr),.MemtoReg(MemToReg),.ALUSrc1(ALUSrc1),.ALUSrc2(ALUSrc2),.ExtOp(ExtOp),.LuOp(LUOp),
					.Sign(Sign),.ALUFun(ALUFun));
	
	wire [31:0] ALUOut;
	wire [31:0] ConBA;
	wire [25:0] JT;
	wire [31:0] Databus_A;
	wire [31:0] Databus_B;
	wire [31:0] Databus_C;
	wire Zero;
	InstructionMemory instructionmemory(.Address(PC),.Instruction(Instruction));
	
	assign JT=Instruction[25:0];
	always @(*)
		if(~reset)
			case(PCSrc)
			3'b000:PC_next<={PC[31],PC[30:0]+31'h4};
			3'b001:PC_next<=Zero?ConBA:{PC[31],PC[30:0]+31'h4};
			3'b010:PC_next<={PC[31:28],JT,2'h0};
			3'b011:PC_next<=Databus_A;
			3'b100:PC_next<=ILLOP;
			3'b101:PC_next<=XADR;
			default:PC_next<=START;
		endcase else
			PC_next<=START;
	
	always @ (posedge reset or posedge clk)
	begin
		if(reset)
			PC<=START;
		else if(if_continue)
			PC<=PC_next;
	end
	
	wire [15:0] Imm16;
	wire [4:0] Shamt;
	wire [4:0] Rd;
	wire [4:0] Rt;
	wire [4:0] Rs;
	assign Imm16=Instruction[15:0];
	assign Shamt=Instruction[10:6];
	assign Rd=Instruction[15:11];
	assign Rt=Instruction[20:16];
	assign Rs=Instruction[25:21];
	
	reg [4:0]AddrC;
	always @ (*)
		case(RegDst)
			2'b00:AddrC<=Rt;
			2'b01:AddrC<=Rd;
			2'b10:AddrC<=5'd31;
			default:AddrC<=5'b0;
		endcase
		
	RegisterFile regfile(.reset(reset),.clk(clk),.RegWrite(RegWr),.Read_register1(Rs),.Read_register2(Rt),.Write_register(AddrC),.Write_data(Databus_C),
						.Read_data1(Databus_A),.Read_data2(Databus_B));
	
	wire [31:0] ImmedNum;
	wire [31:0] ALUA;
	wire [31:0] ALUB;
	wire [31:0] LU_OUT;
	wire [31:0] ALU_OUT;
	assign ImmedNum=ExtOp?{{16{Imm16[15]}},Imm16}:{16'b0,Imm16};
	assign LU_OUT=LUOp?{Imm16,16'b0}:ImmedNum;
	assign ConBA={ImmedNum[29:0],2'b00}+PC+32'd4;
	assign ALUA=ALUSrc1?{27'b0,Shamt}:Databus_A;
	assign ALUB=ALUSrc2?LU_OUT:Databus_B;
	ALU alu(.A(ALUA),.B(ALUB),.ALUFun(ALUFun),.sign(Sign),.Z(ALU_OUT),.Zero(Zero));
	wire [31:0] MemoryAdd = Databus_A+LU_OUT;
	
	wire [31:0] ReadData;
	
	DataMemory datamemory(.reset(reset),.sysclk(sys_clk),.clk(clk),.Uart_Rx(UART_RX),.read_enable(MemRd),
						.write_enable(MemWr),.address(MemoryAdd),.writedata(Databus_B),.switch(switch),
						.led(LED),.tube(TUBE),.Uart_Tx(UART_TX),.readdata(ReadData),.if_continue(if_continue));

	assign Databus_C=(MemToReg==2'b00)?ALU_OUT:
					 (MemToReg==2'b01)?ReadData:{PC[31],PC[30:0]+31'h4};
	
endmodule
