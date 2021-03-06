`timescale 1ns / 1ps
module UARTSender(
input reset,
input sysclk,
input[7:0] TX_DATA,
input trigger,
input enable,
output state,
output wire finish,
output UART_TX
    );
    wire budclk;
    wire status;
    assign state = status;
    reg tmp;
    assign UART_TX = tmp;
    reg[3:0] count;
    
    initial tmp = 1'b1; 
    initial count = 4'b0000;

    always @(posedge budclk or posedge reset)
    begin
        if(reset == 1'b1) begin count <= 4'b0000; end
        else begin
            if(count == 4'b1010) count <= 4'b0000;
            tmp = (count == 4'b0000)?1'b0:
                (count == 4'b0001)?TX_DATA[0]:
                (count == 4'b0010)?TX_DATA[1]:
                (count == 4'b0011)?TX_DATA[2]:
                (count == 4'b0100)?TX_DATA[3]:
                (count == 4'b0101)?TX_DATA[4]:
                (count == 4'b0110)?TX_DATA[5]:
                (count == 4'b0111)?TX_DATA[6]:
                (count == 4'b1000)?TX_DATA[7]:
                (count == 4'b1001)?1'b1:1'b1;
                count = count + 4'b0001;
        end
    end
    reg trigger_reg;
    initial trigger_reg = 1'b0;
    
    reg pos_trigger;
    initial pos_trigger = 1'b0;
    always @(posedge sysclk)
    begin
    if(trigger_reg == 1'b1) trigger_reg = 1'b0;
    else if(pos_trigger != trigger)
            begin
                pos_trigger = trigger;
                if(pos_trigger == 1'b1) trigger_reg = 1'b1;
            end
    end

    BaudGenerator baud(1'b1,sysclk,enable,trigger_reg,finish,status,budclk);
    
endmodule
