module notepad_minus_minus
    (
        input PS2_KBCLK,                            // Keyboard clock
        input PS2_KBDAT,                            // Keyboard input data
        input CLOCK_50,                             //    On Board 50 MHz
        input [0:0] KEY,                            // Reset key
        // The ports below are for the VGA output.  Do not change.
        output VGA_CLK,                             //    VGA Clock
        output VGA_HS,                              //    VGA H_SYNC
        output VGA_VS,                              //    VGA V_SYNC
        output VGA_BLANK_N,                         //    VGA BLANK
        output VGA_SYNC_N,                          //    VGA SYNC
        output [9:0] VGA_R,                         //    VGA Red[9:0]
        output [9:0] VGA_G,                         //    VGA Green[9:0]
        output [9:0] VGA_B                          //    VGA Blue[9:0]
    );
    
    wire resetn;
    assign resetn = KEY[0];
    
    // Create the colour, x, y and writeEn wires that are inputs to the VGA adapter.
    wire [2:0] colour;
    wire [8:0] x;
    wire [7:0] y;
    wire writeEn;
    // Create wires used to transfer signals and data between datapath and FSM
    wire [7:0] pixel_counter_transfer;
    wire [5:0] x_pos_counter_transfer;
    wire [5:0] x_load;
    wire x_parallel;
    wire [5:0] line_pos_counter_transfer;
    wire [5:0] line_load;
    wire line_parallel;
    wire [3:0] y_pos_counter_transfer;
    wire [3:0] y_load;
    wire y_parallel;
    wire inc_pixel_counter_transfer, dec_x_pos_counter_transfer, inc_x_pos_counter_transfer, 
        inc_y_pos_counter_transfer, dec_y_pos_counter_transfer, inc_line_pos_counter_transfer,
        dec_line_pos_counter_transfer;
    wire reset_pixel_counter_transfer, reset_x_pos_counter_transfer, reset_y_pos_counter_transfer,
        reset_line_pos_counter_transfer;
    wire shift_for_cursor_transfer;
    // Create wires used to transfer keyboard input to datapath and FSM
    wire [6:0] ASCII_value;
    wire [7:0] kb_scan_code;
    wire kb_sc_ready, kb_letter_case;
    
    // Create an Instance of a VGA controller - there can be only one!
    // Define the number of colours as well as the initial background
    // image file (.MIF) for the controller.
    vga_adapter VGA
        (
            .resetn(resetn),
            .clock(CLOCK_50),
            .colour(colour),
            .x(x),
            .y(y),
            .plot(writeEn),
            /* Signals for the DAC to drive the monitor. */
            .VGA_R(VGA_R),
            .VGA_G(VGA_G),
            .VGA_B(VGA_B),
            .VGA_HS(VGA_HS),
            .VGA_VS(VGA_VS),
            .VGA_BLANK(VGA_BLANK_N),
            .VGA_SYNC(VGA_SYNC_N),
            .VGA_CLK(VGA_CLK)
        );

    defparam VGA.RESOLUTION = "320x240"; // "160x120" works, for sure
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "black_320.mif";
    
    // Instantiate keyboard input
    keyboard kd
        (
            .clk(CLOCK_50),
            .reset(~resetn),
            .ps2d(PS2_KBDAT),
            .ps2c(PS2_KBCLK),
            .scan_code(kb_scan_code),
            .scan_code_ready(kb_sc_ready),
            .letter_case_out(kb_letter_case)
        );
    
    key2ascii SC2A    
        (
            .ascii_code(ASCII_value),
            .scan_code(kb_scan_code),
            .letter_case(kb_letter_case)
        );
    
   // Instantiate datapath
    datapath d0
        (
            .x_out(x),
            .y_out(y),
            .colour_out(colour),
            .pixel_counter(pixel_counter_transfer),
            .x_pos_counter(x_pos_counter_transfer),
            .y_pos_counter(y_pos_counter_transfer),
            .line_counter(line_pos_counter_transfer),
            .clk(CLOCK_50),
            .reset_n(~resetn),
            .colour_in(3'b010),
            .inc_pixel_counter(inc_pixel_counter_transfer),
            .reset_pixel_counter(reset_pixel_counter_transfer),
            .inc_x_pos_counter(inc_x_pos_counter_transfer),
            .dec_x_pos_counter(dec_x_pos_counter_transfer),
            .x_load(x_load),
            .x_parallel(x_parallel),
            .reset_x_pos_counter(reset_x_pos_counter_transfer),
            .inc_y_pos_counter(inc_y_pos_counter_transfer),
            .dec_y_pos_counter(dec_y_pos_counter_transfer),
            .y_load(y_load),
            .y_parallel(y_parallel),
            .reset_y_pos_counter(reset_y_pos_counter_transfer),
            .inc_line_pos_counter(inc_line_pos_counter_transfer),
            .dec_line_pos_counter(dec_line_pos_counter_transfer),
            .line_load(line_load),
            .line_parallel(line_parallel),
            .reset_line_pos_counter(reset_line_pos_counter_transfer),
            .letter_in(ASCII_value),
            .shift_for_cursor(shift_for_cursor_transfer)
        );

    // Instantiate FSM control
    control_FSM c0
        (
            .plot(writeEn),
            .inc_pixel_counter(inc_pixel_counter_transfer),
            .reset_pixel_counter(reset_pixel_counter_transfer),
            .inc_line_pos_counter(inc_line_pos_counter_transfer),
            .dec_line_pos_counter(dec_line_pos_counter_transfer),
            .line_load(line_load),
            .line_parallel(line_parallel),
            .reset_line_pos_counter(reset_line_pos_counter_transfer),
            .inc_x_pos_counter(inc_x_pos_counter_transfer),
            .dec_x_pos_counter(dec_x_pos_counter_transfer),
            .x_load(x_load),
            .x_parallel(x_parallel),
            .reset_x_pos_counter(reset_x_pos_counter_transfer),
            .inc_y_pos_counter(inc_y_pos_counter_transfer),
            .dec_y_pos_counter(dec_y_pos_counter_transfer),
            .y_load(y_load),
            .y_parallel(y_parallel),
            .reset_y_pos_counter(reset_y_pos_counter_transfer),
            .shift_for_cursor(shift_for_cursor_transfer),
            .clk(CLOCK_50),
            .reset_n(~resetn),
            .char_ready(kb_sc_ready),
            .pixel_counter_in(pixel_counter_transfer),
            .x_pos_counter_in(x_pos_counter_transfer),
            .y_pos_counter_in(y_pos_counter_transfer),
            .line_pos_counter_in(line_pos_counter_transfer),
            .ascii_code(ASCII_value)
        );
endmodule

module datapath
    (
        output reg [8:0] x_out,
        output reg [7:0] y_out,
        output reg [2:0] colour_out,
        output [7:0] pixel_counter,
        output [5:0] line_pos_counter,
        output [5:0] x_pos_counter,
        output [3:0] y_pos_counter,
        input clk,
        input reset_n,
        input [2:0] colour_in,
        input inc_pixel_counter,
        input reset_pixel_counter,
        input inc_x_pos_counter,
        input dec_x_pos_counter,
        input [5:0] x_load,
        input x_parallel,
        input reset_x_pos_counter,
        input inc_y_pos_counter,
        input dec_y_pos_counter,
        input [3:0] y_load,
        input y_parallel,
        input reset_y_pos_counter,
        input inc_line_pos_counter,
        input dec_line_pos_counter,
        input [5:0] line_load,
        input line_parallel,
        input reset_line_pos_counter,
        input [6:0] letter_in,
        input shift_for_cursor
    );
    wire top_shifter_bit;
    wire [127:0] letter_out;
          
    // Instantiate line-position counter
    counter_6bit lineposc0
        (
            .Q_OUT(line_pos_counter),
            .load(line_load),
            .parallel(line_parallel),
            .increase(inc_line_pos_counter),
            .decrease(dec_line_pos_counter),
            .CLK(clk),
            .CLR(reset_line_pos_counter)
        );
    
    // Instantiate relative pixel position pixel_counter
    counter_8bit pxcnt0
        (
            .Q_OUT(pixel_counter), 
            .EN(inc_pixel_counter), 
            .CLK(clk), 
            .CLR(reset_pixel_counter)
        );
    
    // Instantiate x-position counter
    counter_6bit xposc0
        (
            .Q_OUT(x_pos_counter),
            .load(x_load),
            .parallel(x_parallel),
            .increase(inc_x_pos_counter),
            .decrease(dec_x_pos_counter),
            .CLK(clk),
            .CLR(reset_x_pos_counter)
        );
    
    // Instantiate y-position counter
    counter_4bit yposc0
        (
            .Q_OUT(y_pos_counter),
            .load(y_load),
            .parallel(y_parallel),
            .increase(inc_y_pos_counter),
            .decrease(dec_y_pos_counter),
            .CLK(clk),
            .CLR(reset_y_pos_counter)
        );
    
    // Instantiate character decoder
    char_decoder decoder0
        (
            .OUT(letter_out),
            .IN(letter_in)
        );
    
    
    // Instantiate shifter
   shifter_128bit s0
        (
            .result(top_shifter_bit),
            .load_val(letter_out),
            .load_n(reset_pixel_counter),
            .shift(inc_pixel_counter),
            .reset(reset_n),
            .clock(clk)
        );
     
    always @(negedge clk)
    begin: colour_activator
        if (top_shifter_bit)
            colour_out = colour_in;
        else
            colour_out = 3'b000;
    end // colour_activator
    
    always @(posedge clk)
    begin: coordinate_shifter
        if (shift_for_cursor)
            y_out = (y_pos_counter << 4) + 4'd13;
        else if (~inc_pixel_counter)
        begin
            x_out = (x_pos_counter << 3) + pixel_counter[2:0];
            y_out = (y_pos_counter << 4) + pixel_counter[6:3];
        end
    end // coordinate_shifter
endmodule

module control_FSM(
        output reg plot, 
        output reg load_char,
        output reg inc_pixel_counter,
        output reg reset_pixel_counter,
        output reg inc_line_pos_counter,
        output reg dec_line_pos_counter,
        output [5:0] line_load,
        output line_parallel,
        output reg reset_line_pos_counter,
        output reg inc_x_pos_counter,
        output reg dec_x_pos_counter,
        output [5:0] x_load,
        output x_parallel,
        output reg reset_x_pos_counter,
        output reg inc_y_pos_counter,
        output reg dec_y_pos_counter,
        output [3:0] y_load,
        output y_parallel,
        output reg reset_y_pos_counter,
        output reg shift_for_cursor,
        input clk,
        input reset_n,
        input char_ready,
        input [7:0] pixel_counter_in,
        input [5:0] line_pos_counter_in,
        input [5:0] x_pos_counter_in,
        input [3:0] y_pos_counter_in,
        input [6:0] ascii_code
    );
    
    // Instantiate Rate Divider
    rate_divider RD
        (
        .OUT(half_hz_clock),
        .IN(clk)
        );
    
    // Insantiate Cursor pixel counter
    counter_4bit cpc
        (
            .Q_OUT(cusor_pixel_counter),
            .increase(inc_cursor_pixel_counter),
            .CLK(clk),
            .CLR(reset_cursor_pixel_counter)
        );

    reg [4:0] current_state, next_state;
    reg cursor_colour, control_char;
    wire [3:0] cusor_pixel_counter;
    reg inc_cursor_pixel_counter, reset_cursor_pixel_counter;

    localparam  CHAR_SIZE             = 8'd127,
                MAX_X_POS             = 6'd39,
                MAX_Y_POS             = 4'd14,
                MAX_CURSOR_W          = 4'd7;
                
    localparam  S_PLOT_CURSOR           = 5'd0,
                S_PLOT_CURSOR_WAIT      = 5'd1,
                S_CURSOR_INC            = 5'd2,
                S_CURSOR_INC_WAIT       = 5'd3,
                S_FLIP_CURSOR_COLOUR    = 5'd4,
                S_CURSOR_WAIT           = 5'd5,
                S_CHECK_CHAR            = 5'd6,
                S_SAVE_CHAR             = 5'd7,
                S_SAVE_CHAR_WAIT        = 5'd8,
                S_PLOT_PIXEL            = 5'd9,
                S_PLOT_WAIT             = 5'd10,
                S_INC_PIXEL             = 5'd11,
                S_INC_PIXEL_WAIT        = 5'd12,
                S_INC_X_POS             = 5'd13,
                S_INC_X_POS_WAIT        = 5'd14,
                S_INC_Y_POS             = 5'd15,
                S_INC_Y_POS_WAIT        = 5'd16,
                S_START_NEXT_LINE       = 5'd17,
                S_START_LINE            = 5'd18,
                S_END_LINE              = 5'd19,
                S_START_NEXT_PAGE       = 5'd20,
                S_DEC_X_POS             = 5'd21,
                S_DEC_Y_POS             = 5'd22,
                S_SCROLL_UP             = 5'd23,
                S_SCROLL_DOWN           = 5'd24,
                S_END_PREV_LINE         = 5'd25;
                

    localparam  PGUP        = 7'h02, // STX
                PGDWN       = 7'h03, // ETX
                HOME        = 7'h0D, // CR
                UP          = 7'h11, // DC1
                LEFT        = 7'h12, // DC2
                DOWN        = 7'h13, // DC3
                RIGHT       = 7'h14, // DC3
                END         = 7'h17; // ETB
                
    always @(*)
    begin: state_table
        case (current_state)
            S_PLOT_CURSOR:          next_state = char_ready ? S_CHECK_CHAR : S_PLOT_CURSOR_WAIT;
            S_PLOT_CURSOR_WAIT:     next_state = char_ready ? S_CHECK_CHAR : S_CURSOR_INC;
            S_CURSOR_INC:           next_state = char_ready ? S_CHECK_CHAR : S_CURSOR_INC_WAIT;
            S_CURSOR_INC_WAIT:      next_state = char_ready ? S_CHECK_CHAR : cusor_pixel_counter <= MAX_CURSOR_W ? S_PLOT_CURSOR : S_FLIP_CURSOR_COLOUR;
            S_FLIP_CURSOR_COLOUR:   next_state = char_ready ? S_CHECK_CHAR : S_CURSOR_WAIT;
            S_CURSOR_WAIT:          next_state = control_char || char_ready ? S_CHECK_CHAR : half_hz_clock ? S_PLOT_CURSOR : S_CURSOR_WAIT;
            S_CHECK_CHAR:   
                        begin
                            if (ascii_code > 7'h1F && ascii_code < 7'h7F) // if a printing char
                            begin
                                control_char = 1'b0;
                                next_state =  S_SAVE_CHAR;
                            end
                            else if (control_char)
                            begin
                                control_char = 1'b0;
                                case(ascii_code)
                                    UP:     next_state = y_pos_counter_in > 0 ? S_DEC_Y_POS : S_SCROLL_UP;
                                    LEFT:   next_state = x_pos_counter_in > 0 ? S_DEC_X_POS : S_END_PREV_LINE;
                                    DOWN:   next_state = y_pos_counter_in < MAX_Y_POS ? S_INC_Y_POS : S_SCROLL_DOWN;
                                    RIGHT:  next_state = x_pos_counter_in < MAX_X_POS ? S_INC_X_POS : S_START_NEXT_LINE;
                                    HOME:   next_state = S_START_LINE;
                                    END:    next_state = S_END_LINE;
                                    
                                endcase    
                            end
                            else
                            begin
                                control_char = 1'b1;
                                cursor_colour = 1'b0;
                                next_state = S_PLOT_CURSOR;
                            end
                        end
            S_SAVE_CHAR:            next_state = S_SAVE_CHAR_WAIT;
            S_SAVE_CHAR_WAIT:       next_state = S_PLOT_PIXEL;
            S_PLOT_PIXEL:           next_state = S_PLOT_WAIT;
            S_PLOT_WAIT:            next_state = S_INC_PIXEL;
            S_INC_PIXEL:            next_state = S_INC_PIXEL_WAIT;
            S_INC_PIXEL_WAIT:       next_state = (pixel_counter_in <= CHAR_SIZE) ? S_PLOT_PIXEL : S_INC_X_POS;
            S_INC_X_POS:            next_state = S_INC_X_POS_WAIT;
            S_INC_X_POS_WAIT:       next_state = (x_pos_counter_in <= MAX_X_POS) ? S_PLOT_CURSOR : S_START_NEXT_LINE;
            S_INC_Y_POS:            next_state = S_INC_Y_POS_WAIT;
            S_INC_Y_POS_WAIT:       next_state = (y_pos_counter_in <= MAX_Y_POS) ? S_PLOT_CURSOR : S_START_NEXT_PAGE;
            default:                next_state = S_PLOT_CURSOR;
        endcase
    end // state_table
    
    always @(negedge clk)
    begin: enable_signals
        plot = 1'b0;
        load_char = 1'b0;
        inc_pixel_counter = 1'b0;
        reset_pixel_counter = 1'b0;
        inc_x_pos_counter = 1'b0;
        reset_x_pos_counter = 1'b0;
        inc_y_pos_counter = 1'b0;
        reset_y_pos_counter = 1'b0;
        inc_cursor_pixel_counter = 1'b0;
        reset_cursor_pixel_counter = 1'b0;
        case (current_state)
            S_PLOT_CURSOR: 
                                    begin
                                        shift_for_cursor            = 1'b1;
                                        plot                        = 1'b1;
                                    end
            S_CURSOR_INC:               inc_cursor_pixel_counter    = 1'b1;
            S_FLIP_CURSOR_COLOUR:       cursor_colour               = ~cursor_colour;
            S_SAVE_CHAR:
                                    begin
                                        load_char                   = 1'b1;
                                        reset_pixel_counter         = 1'b1;
                                        shift_for_cursor            = 1'b0;
                                    end
            S_PLOT_PIXEL:               plot                        = 1'b1;
            S_INC_PIXEL:                inc_pixel_counter           = 1'b1;
            S_INC_X_POS:                inc_x_pos_counter           = 1'b1;
            S_INC_Y_POS:                inc_y_pos_counter           = 1'b1;
        endcase
    end // enable_signals
    
    always @(posedge clk)
    begin: state_FFs
        current_state = reset_n ? S_PLOT_CURSOR : next_state;
    end // state_FFs
endmodule
