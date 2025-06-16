`default_nettype none
// ksa.sv - SystemVerilog conversion of VHDL ksa entity/architecture

module ksa (
    input  logic       CLOCK_50,        // Clock pin
    input  logic [3:0]  KEY,             // push button switches
    input  logic [9:0]  SW,              // slider switches
    output logic [9:0]  LEDR,            // red lights
    output logic [6:0]  HEX0,
    output logic [6:0]  HEX1,
    output logic [6:0]  HEX2,
    output logic [6:0]  HEX3,
    output logic [6:0]  HEX4,
    output logic [6:0]  HEX5
);
    logic clk;
    logic reset_n;
    // Continuous assignments (combinational)
    assign clk     = CLOCK_50;
    assign reset_n = ~KEY[3]; //active high reset
    assign LEDR = {'0,LEDR_cracker4,LEDR_cracker3,LEDR_cracker2,LEDR_cracker1};
    
    logic [1:0] LEDR_cracker1;
    logic Valid_Key_Found_cracker1;
    logic [23:0] Secret_Key_Cracker_1;
    Cracking_RC4 #(
    .BEGIN_SEARCH(22'd0),
    .END_SEARCH(22'h0FFFFF)//h3FFFFF
    )Cracking_RC4_Core1(
    .clk(clk),        // Clock pin
    .reset_n(reset_n | Valid_Key_Found_rst[0]),
    .LEDR(LEDR_cracker1),
    .Is_Valid_Key_Found(Valid_Key_Found_cracker1),
    .Secret_Key(Secret_Key_Cracker_1),
    );

    logic [1:0] LEDR_cracker2;
    logic Valid_Key_Found_cracker2;
    logic [23:0] Secret_Key_Cracker_2;
    Cracking_RC4 #(
    .BEGIN_SEARCH(22'h100000),
    .END_SEARCH(22'h1FFFFF)//h3FFFFF
    )Cracking_RC4_Core2(
    .clk(clk),        // Clock pin
    .reset_n(reset_n | Valid_Key_Found_rst[1]),
    .LEDR(LEDR_cracker2),
    .Is_Valid_Key_Found(Valid_Key_Found_cracker2),
    .Secret_Key(Secret_Key_Cracker_2),
    );

    logic [1:0] LEDR_cracker3;
    logic Valid_Key_Found_cracker3;
    logic [23:0] Secret_Key_Cracker_3;
    Cracking_RC4 #(
    .BEGIN_SEARCH(22'h200000),
    .END_SEARCH(22'h2FFFFF)//h3FFFFF
    )Cracking_RC4_Core3(
    .clk(clk | Valid_Key_Found_rst[2]),        // Clock pin
    .reset_n(reset_n),
    .LEDR(LEDR_cracker3),
    .Is_Valid_Key_Found(Valid_Key_Found_cracker3),
    .Secret_Key(Secret_Key_Cracker_3),
    );

    logic [1:0] LEDR_cracker4;
    logic Valid_Key_Found_cracker4;
    logic [23:0] Secret_Key_Cracker_4;
    Cracking_RC4 #(
    .BEGIN_SEARCH(22'h300000),
    .END_SEARCH(22'h3FFFFF)//h3FFFFF
    )Cracking_RC4_Core4(
    .clk(clk  | Valid_Key_Found_rst[3]),        // Clock pin
    .reset_n(reset_n),
    .LEDR(LEDR_cracker4),
    .Is_Valid_Key_Found(Valid_Key_Found_cracker4),
    .Secret_Key(Secret_Key_Cracker_4),
    );

    logic [23:0] Secret_Key_Selected;
    logic [3:0] Valid_Key_Found_rst;

    Key_Selecter key_sel_u (
    .clk                         (clk),
    .reset_n                     (reset_n),

    .Valid_Key_Found_cracker1    (Valid_Key_Found_cracker1),
    .Secret_Key_Cracker_1        (Secret_Key_Cracker_1),

    .Valid_Key_Found_cracker2    (Valid_Key_Found_cracker2),
    .Secret_Key_Cracker_2        (Secret_Key_Cracker_2),

    .Valid_Key_Found_cracker3    (Valid_Key_Found_cracker3),
    .Secret_Key_Cracker_3        (Secret_Key_Cracker_3),

    .Valid_Key_Found_cracker4    (Valid_Key_Found_cracker4),
    .Secret_Key_Cracker_4        (Secret_Key_Cracker_4),

    .Secret_Key_Selected         (Secret_Key_Selected),
    .Valid_Key_Found_rst         (Valid_Key_Found_rst)
    );

    SevenSegmentDisplayDecoder
    decoder0 (
        .ssOut(HEX0),
        .nIn  (Secret_Key_Selected[3:0])
    );
    SevenSegmentDisplayDecoder
    decoder1 (
        .ssOut(HEX1),
        .nIn  (Secret_Key_Selected[7:4])
    );
    SevenSegmentDisplayDecoder
    decoder2 (
        .ssOut(HEX2),
        .nIn  (Secret_Key_Selected[11:8])
    );
    SevenSegmentDisplayDecoder
    decoder3 (
        .ssOut(HEX3),
        .nIn  (Secret_Key_Selected[15:12])
    );
    SevenSegmentDisplayDecoder
    decoder4 (
        .ssOut(HEX4),
        .nIn  (Secret_Key_Selected[19:16])
    );
    SevenSegmentDisplayDecoder
    decoder5 (
        .ssOut(HEX5),
        .nIn  (Secret_Key_Selected[23:20])
    );
endmodule 
`default_nettype wire