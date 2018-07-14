module Shift_Left(
	input [31:0]B,
	input [4:0]A,
	output [31:0]Shift
);
	
	wire [31:0]Shift1,Shift2,Shift3,Shift4;
	assign Shift1 = A[4]?{B[15:0],{16{1'b0}}}:B;
	assign Shift2 = A[3]?{Shift1[23:0],{8{1'b0}}}:Shift1;
	assign Shift3 = A[2]?{Shift2[27:0],{4{1'b0}}}:Shift2;
	assign Shift4 = A[1]?{Shift3[29:0],{2{1'b0}}}:Shift3;
	assign Shift  = A[0]?{Shift4[30:0],1'b0}:Shift4;
	
endmodule

module Shift_Right(
	input sign,
	input [31:0]B,
	input [4:0]A,
	output [31:0]Shift
);
	
	wire [31:0]Shift1,Shift2,Shift3,Shift4;
	assign Shift1 = A[4]?{{16{sign}},B[31:16]}:B;
	assign Shift2 = A[3]?{{8{sign}},Shift1[31:8]}:Shift1;
	assign Shift3 = A[2]?{{4{sign}},Shift2[31:4]}:Shift2;
	assign Shift4 = A[1]?{{2{sign}},Shift3[31:2]}:Shift3;
	assign Shift  = A[0]?{sign,Shift4[30:1]}:Shift4;
endmodule

module ALU(
    input [31:0] A,
	input [31:0] B,
	input [5:0] ALUFun,
	input sign,
	output reg [31:0] Z,
	output Zero
	);
	
	reg [31:0]Math,Cmp,Logic,Shift;
	
	assign Zero = (Math == 0);
	assign N = sign && Math[31];
	assign V = sign?
				(ALUFun[0]? ((A[31]^B[31])&&(A[31]^Math[31])) : ((A[31]^Math[31])&&(B[31]^Math[31])))
				:(ALUFun[0]? (A<B) : ((A[31]&&B[31]) || (A[31]||B[31])&&(~Math[31])));
				
	wire [31:0]sll,srl,sra;
	Shift_Left Sh1(B,A[4:0],sll);
	Shift_Right Sh2(1'b0,B,A[4:0],srl);
	Shift_Right Sh3(B[31],B,A[4:0],sra);
	
	always @(*)
	begin
		case(ALUFun[0])
			0:			Math <= A+B;
			1:			Math <= A+(~B)+1;
		endcase
		case(ALUFun[3:0])
			4'b1000:	Logic <= A&B;
			4'b1110:	Logic <= A|B;
			4'b0110:	Logic <= A^B;
			4'b0001:	Logic <= ~(A|B);
			4'b1010:	Logic <= A;
			default:	Logic <= 0;
		endcase
		case(ALUFun[1:0])
			2'b00:		Shift <= sll;			//Shift <= (B << A[4:0]);
			2'b01:		Shift <= srl;			//Shift <= (B >> A[4:0]);
			2'b11:		Shift <= sra;			//Shift <= ({{32{B[31]}},B} >> A[4:0]);
			default:	Shift <= 0;
		endcase
		case(ALUFun[3:1])
			3'b001:		Cmp <= Zero;
			3'b000:		Cmp <= ~Zero;
			3'b010:		Cmp <= sign?(Math[31]^V):V;
			3'b110:		Cmp <= sign?(A[31]||(A == 0)):(A == 0);
			3'b101:		Cmp <= sign?A[31]:0;
			3'b111:		Cmp <= sign?(~A[31]&&(A != 0)):(A != 0);
			default:	Cmp <= 0;
		endcase
		case(ALUFun[5:4])
			2'b00:		Z <= Math;
			2'b01:		Z <= Logic;
			2'b10:		Z <= Shift;
			2'b11:		Z <= Cmp;
		endcase
	end
endmodule