module counter_8bit
	(
		output reg [7:0] Q_OUT, 
		input EN, 
		input CLK, 
		input CLR
	);
	always @(posedge CLK)
	begin
		if (EN == 1'b1 | CLR == 1'b1)
		begin
			if (CLR == 1'b1)
				Q_OUT[7:0] <= 8'b0000_0000;
			else if (CLK == 1'b1)
			   Q_OUT[7:0] <= Q_OUT[7:0] + 8'b0000_00001;
		end
	end
endmodule
