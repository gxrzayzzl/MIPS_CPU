module BaudGenerator(
input sysclk,
input trigger,
input enable,
output status,
output bud_clk
    );
    
    reg[12:0] state;
    reg[4:0] count;
    reg tmp;
    assign bud_clk = tmp;
    reg Status;
    assign status = Status;
    
    initial Status = 1'b0;
    
    always @(posedge sysclk)
    begin
        if(Status == 1'b0 && trigger == 1'b1 && enable == 1'b1)
        begin
            Status = 1'b1;
            count = 5'b0_0000;
            state = 13'b0_0000_0000_0000;
        end else if(Status == 1'b1)
        begin
            state = state + 13'b0_0000_0000_0001;
            if(tmp == 1'b1) tmp = ~tmp;
            if(count != 5'b10100)
            begin
                if(state == 13'b1_0100_0101_1000) 
                begin
                    if(count[0] == 1'b0 && count != 5'b10010) tmp = 1'b1;
                    state = 13'b0_0000_0000_0000;
                    count = count + 5'b00001;
                end
            end else Status = 1'b0;
        end
    end
      
endmodule
