`timescale 1ns / 1ps
module Timer(
input clk,
input[1:0] timer_CON,
input[31:0] TL,
output reg timer_State,
output wire[31:0] TH
    );
    
    reg[31:0] THreg;
    assign TH = THreg;
	initial timer_State=1'b1;
    
    always@(posedge clk)
    if(timer_CON[0] == 1'b1)
    begin
        if(THreg != 32'hffffffff)
            THreg = THreg + 32'b1;
        else
            begin if(timer_CON[1] == 1) timer_State = 1'b1; 
            THreg = TL;
            end
    end else THreg = 32'hffffffff;
    
    
endmodule
