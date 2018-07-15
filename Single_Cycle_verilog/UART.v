`timescale 1ns / 1ps
module UART(
input clk,
input sysclk,
input Uart_state_trigger,
input UART_RX,
input[7:0] writedata,
input recv_enable,
input send_enable,
input send_trigger,
output send_state,
output recv_state,
output send_work_state,
output UART_TX,
output[7:0] readdata
    );
    
    reg send_state_reg;
    assign send_state = send_state_reg;
    reg recv_state_reg;
    assign recv_state = recv_state_reg;
    
    wire send_finish;
    wire recv_finish;
    assign recv_finish = ~recv_state;
    
    always @(posedge sysclk)
        begin if(Uart_state_trigger == 1'b1) begin send_state_reg <= 1'b0; recv_state_reg <= 1'b0; end
        else begin
        if(send_finish == 1'b1) send_state_reg <= send_finish;
        if(recv_finish == 1'b1) recv_state_reg <= recv_finish;
            end
        end
    
    
    UARTReceiver recv(sysclk,UART_RX,recv_enable,recv_finish,readdata);
    UARTSender send(sysclk,writedata,send_trigger,send_enable,send_work_state,send_finish,UART_TX);
    
endmodule
