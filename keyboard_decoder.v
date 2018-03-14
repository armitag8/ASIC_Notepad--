module keyboard_decoder(
	input PS2_KBCLK,
	input PS2_KBDAT,
   output [6:0] ASCII_value
	);

	wire [7:0] data_out;
	wire [6:0] acsii_code;
	
	assign ASCII_value[6:0] = acsii_code;
	
	keyboard_output kb(
	.clk(PS2_KBCLK),
	.data(PS2_KBDAT),
	.data_out(data_out[7:0])
	);

	translate_to_ASCII tta(
	.data(data_out[7:0]),
	.OUT(acsii_code[6:0])
	);
endmodule

module translate_to_ASCII(
	input [7:0] data,
	output reg [6:0] OUT
);
	
	always @(*)
	begin
		case(data[7:0])
			8'b00101001: OUT = 7'd32; // space
			8'b01000101: OUT = 7'd48; // '0'
			8'b00010110: OUT = 7'd49; // '1'
			8'b00011110: OUT = 7'd50; // '2'
			8'b00100110: OUT = 7'd51; // '3'
			8'b00100101: OUT = 7'd52; // '4'
			8'b00101110: OUT = 7'd53; // '5'
			8'b00110110: OUT = 7'd54; // '6'
			8'b00111101: OUT = 7'd55; // '7'
			8'b00111110: OUT = 7'd56; // '8'
			8'b01000110: OUT = 7'd57; // '9'
			8'b00011100: OUT = 7'd65; // 'A'
			8'b00110010: OUT = 7'd66; // 'B'
			8'b00100001: OUT = 7'd67; // 'C'
			8'b00100011: OUT = 7'd68; // 'D'
			8'b00100100: OUT = 7'd69; // 'E'
			8'b00101011: OUT = 7'd70; // 'F'
			8'b00110100: OUT = 7'd71; // 'G'
			8'b00110011: OUT = 7'd72; // 'H'
			8'b01000011: OUT = 7'd73; // 'I'
			8'b00111011: OUT = 7'd74; // 'J'
			8'b01000010: OUT = 7'd75; // 'K'
			8'b01001011: OUT = 7'd76; // 'L'
			8'b00111010: OUT = 7'd77; // 'M'
			8'b00110001: OUT = 7'd78; // 'N'
			8'b01000100: OUT = 7'd79; // 'O'
			8'b01001101: OUT = 7'd80; // 'P'
			8'b00010101: OUT = 7'd81; // 'Q'
			8'b00101101: OUT = 7'd82; // 'R'
			8'b00011011: OUT = 7'd83; // 'S'
			8'b00101100: OUT = 7'd84; // 'T'
			8'b00111100: OUT = 7'd85; // 'U'
			8'b00101010: OUT = 7'd86; // 'V'
			8'b00011101: OUT = 7'd87; // 'W'
			8'b00100010: OUT = 7'd88; // 'X'
			8'b00110101: OUT = 7'd89; // 'Y'
			8'b00011010: OUT = 7'd90; // 'Z'
    		default: OUT = 7'd32;
		endcase
	end
	
endmodule

module keyboard_output(
    input wire clk, // Clock pin form keyboard
    input wire data, //Data pin form keyboard
    output reg [7:0] data_out //Printing input data to data_out
    );
    reg [7:0] data_curr;
    reg [7:0] data_pre;
    reg [3:0] b;
    reg flag;
    
    initial
    begin
        b<=4'h1;
        flag<=1'b0;
        data_curr<=8'hf0;
        data_pre<=8'hf0;
        data_out<=8'hf0;
    end
        
    always @(negedge clk) //Activating at negative edge of clock from keyboard
    begin
    
    case(b)
        1:; //first bit
        2:data_curr[0]<=data;
        3:data_curr[1]<=data;
        4:data_curr[2]<=data;
        5:data_curr[3]<=data;
        6:data_curr[4]<=data;
        7:data_curr[5]<=data;
        8:data_curr[6]<=data;
        9:data_curr[7]<=data;
        10:flag<=1'b1; //Parity bit
        11:flag<=1'b0; //Ending bit
    endcase
    
    if(b<=10)
        b<=b+1;
    else if(b==11)
        b<=1;
    end
    
    always@(posedge flag) // Printing data obtained to data_out
    begin
    if(data_curr==8'hf0)
			data_out<=data_pre;
    else
        data_pre<=data_curr;
    end
endmodule