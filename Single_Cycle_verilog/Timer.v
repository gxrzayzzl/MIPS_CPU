`timescale 1ns / 1ps
module Timer(
input clk,
input[1:0] timer_CON,
input[31:0] TH,
output reg timer_State,
output wire[31:0] TL
    );
    
    reg[31:0] TLreg;
    assign TL = TLreg;
	initial timer_State=1'b1;
    
    always@(posedge clk)
    if(timer_CON[0] == 1'b1)
    begin
        if(TLreg != 32'hffffffff)begin
			timer_State = 1'b0;
            TLreg = TLreg + 32'b1;end
        else
            begin if(timer_CON[1] == 1) timer_State = 1'b1; 
            end
    end else TLreg = TH;
    
    
endmodule
