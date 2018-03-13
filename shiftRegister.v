module shiftRegister(value, shift, assign, reset, clock, result)
    input [127:0] value;
    input shift;
    input clock;
    input reset;
    input assign;
    output result;
    
    reg pixel[127:0];
    
    assign result = output[127];
    
    always @(posedge clock)
	begin 
        if(reset == 1'b0)
            pixel <= 128'd0;
        else if (assign == 1'b1)
            pixel <= value;
        else if (shift == 1'b1)
            pixel << 1'b0;
    end

endmodule