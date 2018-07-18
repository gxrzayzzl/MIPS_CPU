module CPU_P(sys_clk, reset, UART_TX, UART_RX, LED, TUBE );
    input sys_clk;
    input reset;
    input UART_RX;
    output UART_TX;
    output [7:0] LED;
    output [17:0] TUBE;
        
	parameter ILLOP=32'h80000004;
	parameter XADR=32'h80000008;
	parameter START=32'h00000000;
	
	wire clk;	
	divide div(sys_clk,clk);
	
//	IF	######################################################################
	reg [31:0] PC;
	reg [31:0] PC_next;
	wire [31:0] PC4;
	wire [31:0] Instruction;
	wire [2:0] PCSrc0,PCSrc;
	wire Branch;
	reg  Stall;
	wire if_continue;
	initial Stall<=1'b0;
	wire [31:0] BranchAddr,JumpAddr,JrAddr;
	
	InstructionMemory instructionmemory(.Address(PC),.Instruction(Instruction));
	
	assign PC4 = {PC[31],PC[30:0]+4};
	assign PCSrc = Branch?3'b001:PCSrc0;
	always @(*)
	if(~reset)
		case(PCSrc)														//directly get PCSrc from ID
		3'b000:PC_next <= PC4;
		3'b001:PC_next <= BranchAddr;									//useless
		3'b010:PC_next <= JumpAddr;
		3'b011:PC_next <= JrAddr;
		3'b100:PC_next <= ILLOP;
		3'b101:PC_next <= XADR;
		default:PC_next <= START;
	endcase else
		PC_next <= START;
		
	always @(posedge reset or posedge clk)
	begin
	if (reset)
		PC <= START;
	else if((~Stall)&&(if_continue))
		PC <= PC_next;
	end
		
//	IF/ID	##################################################################
	reg [31:0]PC4_ID,Instruction_ID,PC_ID;
	wire IF_Flush;
	
	always@(posedge reset or posedge clk)
	begin
	if (reset||IF_Flush)
		begin
		PC4_ID <= 0;
		PC_ID <= 0;
		Instruction_ID <= 0;
		end
	else if((~Stall)&&(if_continue))
		begin
		PC4_ID <= PC4;
		PC_ID <= PC;
		Instruction_ID <= Instruction;
		end
	end
		
	
//	ID	######################################################################
	wire [1:0] RegDst;
	wire RegWrite;
	wire ALUSrc1;
	wire ALUSrc2;
	wire [5:0]ALUFun;
	wire Sign;
	wire MemWrite;
	wire MemRead;
	wire [1:0] MemtoReg;
	wire ExtOp;
	wire LUOp;
	wire BranchType,JumpType;
	reg IRQ;
	
	initial begin IRQ<=1'b0;end
	
	Control control(.OpCode(Instruction_ID[31:26]),.Funct(Instruction_ID[5:0]),.IRQ(IRQ),.PC_31(PC_ID[31]),		//PC?
					.PCSrc(PCSrc0),.RegWrite(RegWrite),.RegDst(RegDst),.MemRead(MemRead),.MemWrite(MemWrite),.MemtoReg(MemtoReg),.ALUSrc1(ALUSrc1),.ALUSrc2(ALUSrc2),.ExtOp(ExtOp),.LuOp(LUOp),
					.Sign(Sign),.ALUFun(ALUFun),.BranchType(BranchType),.JumpType(JumpType));
					
	assign IF_Flush=Branch||JumpType||(IRQ&&~PC_ID[31]);
	
	wire [15:0] Imm16;
	wire [4:0] Shamt;
	wire [4:0] RdAddr;
	wire [4:0] RtAddr;
	wire [4:0] RsAddr;
	wire [4:0] RegWrAddr;
	reg [4:0] RegWrAddr_EX,RegWrAddr_WB;
	reg RegWrite_WB,MemRead_EX;
	wire [31:0] RegWrData,RsData,RtData;
	
	assign Imm16 = Instruction_ID[15:0];
	assign Shamt = Instruction_ID[10:6];
	assign RdAddr = Instruction_ID[15:11];
	assign RtAddr = Instruction_ID[20:16];
	assign RsAddr = Instruction_ID[25:21];

	assign RegWrAddr = (RegDst == 2'b00)? RtAddr: 
						(RegDst == 2'b01)? RdAddr: 
						(RegDst == 2'b10)? 5'd31: 5'd26;
	
	RegisterFile regfile(.reset(reset),.clk(clk),.RegWrite(RegWrite_WB),.Read_register1(RsAddr),.Read_register2(RtAddr),.Write_register(RegWrAddr_WB),.Write_data(RegWrData),
						.Read_data1(RsData),.Read_data2(RtData));
	
	always @(posedge clk)
	begin
		if(Stall)Stall<=1'b0;
		else if(((RegWrAddr_EX==RsAddr)||(RegWrAddr_EX==RtAddr))&&MemRead_EX)Stall<=1'b1;
	end
	//assign Stall=((RegWrAddr_EX==RsAddr)||(RegWrAddr_EX==RtAddr))&&MemRead_EX;		//IRQ PC31?
	
	wire [31:0] Imm32;
	assign Imm32 = LUOp?{Imm16,16'b0}:
					ExtOp?{{16{Imm16[15]}},Imm16}:{16'b0,Imm16};
	assign JumpAddr = {PC4_ID[31:28],Instruction_ID[25:0],2'b00};
	assign JrAddr = RsData;
	
//	ID/EX	######################################################################
	reg [31:0]Imm32_EX,RsData_EX,RtData_EX,PC4_EX;
	reg [4:0]Shamt_EX,RsAddr_EX,RtAddr_EX,RdAddr_EX;
	reg [1:0]MemtoReg_EX;
	reg RegWrite_EX,MemWrite_EX,ALUSrc1_EX,ALUSrc2_EX,Sign_EX,BranchType_EX;
	reg [5:0]ALUFun_EX;
	reg OpCode_EX;
	
	always@(posedge reset or posedge clk)
	begin
	if (reset||Branch)
		begin
		Imm32_EX <= 0;
		RsData_EX <= 0;
		RtData_EX <= 0;
		Shamt_EX <= 0;
		RsAddr_EX <= 0;
		RtAddr_EX <= 0;
		RdAddr_EX <= 0;
		//RegWrAddr_EX <= 0;
		RegWrAddr_EX <= 5'b00000;
		MemtoReg_EX <= 0;
		RegWrite_EX <= 0;
		MemRead_EX <= 0;
		MemWrite_EX <= 0;
		ALUSrc1_EX <= 0;
		ALUSrc2_EX <= 0;
		Sign_EX <= 0;
		ALUFun_EX <= 0;
		BranchType_EX <= 0;
		PC4_EX <= 0;
		end
	else if((~Stall)&&(if_continue))
		begin
		Imm32_EX <= Imm32;
		RsData_EX <= RsData;
		RtData_EX <= RtData;
		Shamt_EX <= Shamt;
		RsAddr_EX <= RsAddr;
		RtAddr_EX <= RtAddr;
		RdAddr_EX <= RdAddr;
		//RegWrAddr_EX <= RegDst;
		RegWrAddr_EX <= RegWrAddr;
		MemtoReg_EX <= MemtoReg;
		RegWrite_EX <= RegWrite;
		MemRead_EX <= MemRead;
		MemWrite_EX <= MemWrite;
		ALUSrc1_EX <= ALUSrc1;
		ALUSrc2_EX <= ALUSrc2;
		Sign_EX <= Sign;
		ALUFun_EX <= ALUFun;
		BranchType_EX <= BranchType;
		PC4_EX <= (IRQ&&~PC_ID[31])?(PC4_ID-4):PC4_ID;
		OpCode_EX<=Instruction_ID[31:26];
		end
	end


//	EX	######################################################################
	wire [31:0] ALUA;
	wire [31:0] ALUB;
	wire [31:0] ALUOUT;
	wire [1:0] ForwardA,ForwardB;
	wire MemData;
	reg RegWrite_MEM;
	reg [4:0]RegWrAddr_MEM;
	reg [31:0]ALUOUT_MEM;
	
	Forwarding forwarding(.OpCode_EX(OpCode_EX),.MemWrite_Ex(MemWrite_EX),.RegWrite_MEM(RegWrite_MEM),.RegWrAddr_MEM(RegWrAddr_MEM),.RsAddr_EX(RsAddr_EX),.RtAddr_EX(RtAddr_EX),.RegWrite_WB(RegWrite_WB),.RegWrAddr_WB(RegWrAddr_WB),
				.ForwardA(ForwardA),.ForwardB(ForwardB),.MemData(MemData));
				
	assign ALUA = ALUSrc1_EX?{27'b0,Shamt_EX}:
				(ForwardA==2'b10)?ALUOUT_MEM:
				(ForwardA==2'b01)?RegWrData:RsData_EX;
	assign ALUB = ALUSrc2_EX?Imm32_EX:
				(ForwardB==2'b10)?ALUOUT_MEM:
				(ForwardB==2'b01)?RegWrData:RtData_EX;
	
	ALU alu(.A(ALUA),.B(ALUB),.ALUFun(ALUFun_EX),.sign(Sign_EX),.ALUOUT(ALUOUT));
	
	assign Branch = BranchType_EX && ALUOUT[0];
	assign BranchAddr = {PC4_EX[31],PC4_EX[30:0]+{Imm32_EX[28:0],2'b00}};
	
//	EX/MEM	######################################################################
	reg [31:0]MemWrData_MEM,PC4_MEM;
	reg MemRead_MEM,MemWrite_MEM;
	reg [1:0]MemtoReg_MEM;
	
	always@(posedge reset or posedge clk)
	begin
	if (reset)
		begin
		RegWrAddr_MEM <= 0;
		MemWrData_MEM <= 0;
		ALUOUT_MEM <= 0;
		MemtoReg_MEM <= 0;
		RegWrite_MEM <= 0;
		MemRead_MEM <= 0;
		MemWrite_MEM <= 0;
		PC4_MEM <= 0;
		end
	else 
		begin
		//RegWrAddr_MEM <= RegWrAddr;
		RegWrAddr_MEM <= RegWrAddr_EX;
		MemWrData_MEM <= MemData?ALUOUT_MEM:RtData_EX;
		ALUOUT_MEM <= ALUOUT;
		MemtoReg_MEM <= MemtoReg_EX;
		RegWrite_MEM <= RegWrite_EX;
		MemRead_MEM <= MemRead_EX;
		MemWrite_MEM <= MemWrite_EX;
		PC4_MEM <= PC4_EX;
		end
	end
	
//	MEM	######################################################################
	wire [7:0]switch;
	wire [31:0]MemRdData;
	
	DataMemory datamemory(.reset(reset),.sysclk(sys_clk),.clk(clk),.Uart_Rx(UART_RX),.read_enable(MemRead_MEM),
						.write_enable(MemWrite_MEM),.address(ALUOUT_MEM),.writedata(MemWrData_MEM),.switch(switch),
						.led(LED),.tube(TUBE),.Uart_Tx(UART_TX),.readdata(MemRdData),.if_continue(if_continue));
	
//	MEM/WB	######################################################################
	reg [31:0]MemRdData_WB,ALUOUT_WB,PC4_WB;
	reg [1:0]MemtoReg_WB;
	
	always@(posedge reset or posedge clk)
	begin
	if (reset)
		begin
		RegWrAddr_WB <= 0;
		MemRdData_WB <= 0;
		ALUOUT_WB <= 0;
		MemtoReg_WB <= 0;
		RegWrite_WB <= 0; 
		PC4_WB <= 0;
		end
	else 
		begin
		RegWrAddr_WB <= RegWrAddr_MEM;
		MemRdData_WB <= MemRdData;
		ALUOUT_WB <= ALUOUT_MEM;
		MemtoReg_WB <= MemtoReg_MEM;
		RegWrite_WB <= RegWrite_MEM;
		PC4_WB<=PC4_MEM;
		end
	end
	
//	WB	######################################################################
	assign RegWrData = (MemtoReg_WB == 2'b00)?ALUOUT_WB:
					 (MemtoReg_WB == 2'b01)?MemRdData_WB:PC4_WB;
	
	
endmodule 