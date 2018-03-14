module shifter_128bit
	(
		output result,
		input [127:0] load_val,
		input load_n, 
		input shift, 
		input reset, 
		input clock
	);
    
    reg [127:0] pixel;
    
    assign result = pixel[127];
    
    always @(posedge clock)
	begin 
        if(reset == 1'b1)
            pixel <= {128{1'b0}};
        else if (load_n == 1'b1)
            pixel <= load_val;
        else if (shift == 1'b1)
            pixel <= pixel << 1;
    end
endmodule
