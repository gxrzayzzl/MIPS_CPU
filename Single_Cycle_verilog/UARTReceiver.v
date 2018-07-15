`timescale 1ns / 1ps
module UARTReceiver(
input sysclk,
input UART_RX,
input enable,
output state,
output fin,
output[7:0] data
);
    wire budclk;
    reg[7:0] datareg;
    reg State;
	initial begin datareg<={8'b0}; State = 1'b0; end
    assign data = datareg;
    wire status;
    assign state = State;
    wire finish;
    assign fin = finish;
    
    always @(negedge status or posedge status)
    begin
        if(status == 1'b1) State = 1'b0;
        else State = 1'b1;
    end
    
    always @(posedge budclk)
    begin
        if(enable) datareg = {UART_RX,datareg[7:1]};
    end

    BaudGenerator baud(sysclk,enable,~UART_RX,status,finish,budclk);
    
endmodule