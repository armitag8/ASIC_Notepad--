module counter_6bit
    (
        output reg [5:0] Q_OUT, 
        input EN, 
        input CLK, 
        input CLR
    );
    initial
    begin
        Q_OUT = 6'b00_0000;
    end

    always @(posedge CLK)
    begin
        if (EN == 1'b1 | CLR == 1'b1)
        begin
            if (CLR == 1'b1)
                Q_OUT[5:0] <= 6'b00_0000;
            else if (CLK == 1'b1)
               Q_OUT[5:0] <= Q_OUT[5:0] + 6'b00_0001;
        end
    end

endmodule
