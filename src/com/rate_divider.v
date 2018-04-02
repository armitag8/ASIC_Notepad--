module rate_divider
    (
        output reg OUT,
        input IN
    );
    
    reg [27:0] COUNTER;
    localparam MAX = 28'd25_000_000;
    
    always @(posedge IN)
    begin
        if (COUNTER == 0) 
            OUT <= 1'b0;
        COUNTER <= COUNTER + 1'b1;
        if (COUNTER == MAX)
        begin
            OUT <= 1'b1;
            COUNTER <= 0;
        end            
    end

endmodule