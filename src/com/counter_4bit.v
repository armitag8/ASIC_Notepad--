module counter_4bit
	(
		output reg [3:0] Q_OUT, 
		input EN, 
		input CLK, 
		input CLR
	);
    initial
    begin
        Q_OUT = 4'b0000;
    end
    
	always @(posedge CLK)
	begin
		if (EN == 1'b1 | CLR == 1'b1)
		begin
			if (CLR == 1'b1)
				Q_OUT[3:0] <= 4'b0000;
			else if (CLK == 1'b1)
			   Q_OUT[3:0] <= Q_OUT[3:0] + 4'b0001;
		end
	end
endmodule
