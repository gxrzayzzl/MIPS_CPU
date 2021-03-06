`timescale 1ns / 1ps
module UART(
input reset,
input sysclk,
input Uart_state_trigger,
input UART_RX,
input[7:0] writedata,
input recv_enable,
input send_enable,
input send_trigger,
output wire send_work_state,
output recv_state,
output send_state,
output wire UART_TX,
output[7:0] readdata
    );
    
    reg send_state_reg;
    assign send_state = send_state_reg;
    reg recv_state_reg;
    assign recv_state = recv_state_reg;
    
    wire send_finish;
    wire recv_finish;
    
    wire trigger;
    assign trigger = ~Uart_state_trigger;
    wire Op_send_trigger;
    assign Op_send_trigger = ~send_trigger;

    initial begin recv_state_reg = 1'b0; send_state_reg = 1'b1; end
    
    always @(posedge Op_send_trigger or posedge send_finish or posedge reset)
        begin if(send_finish == 1'b1 && reset == 1'b0) send_state_reg <= 1'b1;
        else send_state_reg <= 1'b0;
        end
    
    always @(posedge trigger or posedge recv_finish or posedge reset)
        begin if(recv_finish == 1'b1 && reset == 1'b0) recv_state_reg <= 1'b1;
        else recv_state_reg <= 1'b0;
        end
    
    UARTReceiver recv(reset,sysclk,UART_RX,recv_enable,recv_finish,readdata);
    UARTSender send(reset,sysclk,writedata,send_trigger,send_enable,send_work_state,send_finish,UART_TX);
    
endmodule
