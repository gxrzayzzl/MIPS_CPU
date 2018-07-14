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
    assign data = datareg;
    wire status;
    assign state = status;
    
    always @(posedge budclk)
    begin
        if(enable) datareg = {~UART_RX,datareg[7:1]};
    end

    BaudGenerator baud(sysclk,enable,~UART_RX,status,budclk);
    
endmodule