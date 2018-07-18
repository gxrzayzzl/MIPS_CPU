`timescale 1ns / 1ps
module UARTReceiver(
input sysclk,
input UART_RX,
input enable,
output state,
output[7:0] data
);
    wire budclk;
    reg[7:0] datareg;
	initial datareg<={8'b1111_1111};
    assign data = ~datareg;
    wire status;
    wire finish;
    reg finish_reg;
    always@(*) finish_reg = finish;
    assign state = finish_reg;
    
    always @(posedge budclk)
    begin
        if(enable) datareg = {~UART_RX,datareg[7:1]};
    end

    BaudGenerator baud(sysclk,enable,~UART_RX,finish,status,budclk);
    
endmodule