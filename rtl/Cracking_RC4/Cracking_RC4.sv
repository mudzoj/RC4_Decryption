// `default_nettype none

// module Cracking_RC4 (
//     input  logic       CLOCK_50,        // Clock pin
//     input  logic [3:0]  KEY,             // push button switches
//     input  logic [9:0]  SW,              // slider switches
//     output logic [9:0]  LEDR,            // red lights
//     output logic [6:0]  HEX0,
//     output logic [6:0]  HEX1,
//     output logic [6:0]  HEX2,
//     output logic [6:0]  HEX3,
//     output logic [6:0]  HEX4,
//     output logic [6:0]  HEX5
// );
//     logic clk;
//     logic reset_n;
//     // Continuous assignments (combinational)
//     assign clk     = CLOCK_50;
//     assign reset_n = ~KEY[3]; //active high reset

//     logic [23:0] Secret_Key_Instance;
//     logic Decrypt_Valid;
//     logic Checker_Finish;
//     logic Check_Ack;

//     module ksa (
//     .CLOCK_50(CLOCK_50),        // Clock pin
//     .KEY(KEY),             // push button switches
//     .SW(SW),              // slider switches
//     .LEDR(LEDR),            // red lights
//     .HEX0(HEX0),
//     .HEX1(HEX1),
//     .HEX2(HEX2),
//     .HEX3(HEX3),
//     .HEX4(HEX4),
//     .HEX5(HEX5),
//     .Secret_Key_Instance(Secret_Key_Instance), //TODO: add to KSA module, feed into instead of switches
//     .Decrypt_Valid(Decrypt_Valid),  //TODO: add to KSA module as output, from checker module
//     .Checker_Finish(Checker_Finish) //TODO: add to KSA module as output, from checker module
// );

    


//     SevenSegmentDisplayDecoder
//     decoder0 (
//         .ssOut(HEX0),
//         .nIn  (SW[3:0])
//     );

// endmodule 
// `default_nettype wire