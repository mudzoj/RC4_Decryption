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
    logic Init_Start,Shuffle_A_Start,Shuffle_B_Start,Decrypt_Start;
    logic Decrypt_done;
    logic [2:0] Mem_sel;


    logic [23:0] Secret_Key_Instance;
    logic Check_Ack;
    logic Control_Start;
    logic Crack_Start;
    
    FSM_Get_Key 
	Get_Next_Secret_Key(
        .clk(clk),
        .rst(reset_n),
        .Crack_Start(1'b1),
        .Secret_Key(Secret_Key_Instance),
        .Key_Valid(Key_Valid),
        .Checker_Finish(Decrypt_done),
        .Check_Ack(Check_Ack),
        .Control_Start(Control_Start),
        .LEDR(LEDR)
    );

    logic Key_Valid;
    FSM_Controller
    FSM_ksa_Controller(
    .clk(clk), 
    .Controller_Start(Control_Start), .Finish_ack(Check_Ack),
    .Init_Finish(Init_Finish),.Shuffle_A_Finish(Shuffle_A_Finish),.Shuffle_B_Finish(Shuffle_B_Finish),.Decrypt_Finish(Checker_Finish),
    .Init_Start(Init_Start),.Shuffle_A_Start(Shuffle_A_Start),.Shuffle_B_Start(Shuffle_B_Start),.Decrypt_Start(Decrypt_Start),
    .Decrypt_done(Decrypt_done), .Decrypt_Valid(Decrypt_Valid),.Key_Valid(Key_Valid),
    .Mem_sel(Mem_sel),
    .rst(reset_n));

    
    logic [7:0] Init_Address;
    logic Init_wren,Init_Finish;
    
    FSM_Init 
    FSM_Initialiser(
        .CLOCK_50(clk),        // Clock pin
        .rst(reset_n),
        .In_Start(Init_Start),             
        .Init_Finish(Init_Finish),
        .Finish_ack(Shuffle_A_Start),
        .Address(Init_Address),
        .wren(Init_wren)
    );



    logic [7:0] q_S;
    logic [7:0] shuffleA_Address, shuffleA_data;
    logic Shuffle_A_Finish, shuffleA_wren;
    
    FSM_Shuffler
    FSM_Shuffle(
    .clk(clk),
    .rst(reset_n),
    .Secret_Key(Secret_Key_Instance), 
    .In_Start(Shuffle_A_Start),
    .Finish_ack(Shuffle_B_Start),
    .q(q_S),
    .data(shuffleA_data),
    .Address(shuffleA_Address),
    .Init_Finish(Shuffle_A_Finish),
    .wren(shuffleA_wren)
);


//=======================================================================================================================
//
//    Working Memory & Working Memory Access Mux
//
//========================================================================================================================
    logic s_selected_wren;
    logic [7:0] s_selected_data, s_selected_Address;
    FSM_MUX
    FSM_MEM_MUX(
    .Mem_sel(Mem_sel),        // select one of eight FSMs
    
    .init_wren(Init_wren),
    .init_data(Init_Address),
    .init_Address(Init_Address),

    // .shuffleA_wren('0),
    // .shuffleA_data('0),
    // .shuffleA_Address('0),

    .shuffleA_wren(shuffleA_wren),
    .shuffleA_data(shuffleA_data),
    .shuffleA_Address(shuffleA_Address),

    .shuffleB_wren(shuffleB_wren_S),
    .shuffleB_data(shuffleB_S_Data),
    .shuffleB_Address(shuffleB_S_Address),

    .decrypt_wren('0),
    .decrypt_data('0),
    .decrypt_Address('0),

    .selected_wren(s_selected_wren),
    .selected_data(s_selected_data),
    .selected_Address(s_selected_Address)
);
    
    s_memory
    s_memory_working (
        .address(s_selected_Address),//TODO replace value
        .clock(clk),
        .data(s_selected_data),//TODO replace value
        .wren(s_selected_wren),//TODO replace value
        .q(q_S)
    );
//=======================================================================================================================
//
//   Shuffler B (task 2b) 
//
//========================================================================================================================
    logic [7:0] shuffleB_D_Address, shuffleB_D_Data;
    logic [7:0] shuffleB_S_Address, shuffleB_S_Data;
    logic Shuffle_B_Finish, shuffleB_wren_S;

    FSM_Shuffler_B
    FSM_Shuffle_B(
    .clk(clk),
    .rst(reset_n),

    .Shuffle_B_Start(Shuffle_B_Start),
    .Finish_ack(Decrypt_Start),

    .q_S(q_S), // working memory
    .data_S(shuffleB_S_Data),
    .Address_S(shuffleB_S_Address),
    
    .q_D(q_D), // Decrypted RAM memory (output)
    .data_D(shuffleB_D_Data),
    .Address_D(shuffleB_D_Address),

    .q_C(q_C_mem), // Encypted msg (ROM)
    .Address_C(C_selected_Address),

    .Shuffle_B_Finish(Shuffle_B_Finish),
    .wren_S(shuffleB_wren_S),
    .wren_D(d_wren)
    );
    
    
    logic [7:0] q_C_mem;
    logic [4:0] C_selected_Address;
    
    ROM_C_memory 
    ROM_msg_C_memory (
	.address(C_selected_Address),//C_selected_Address
	.clock(clk),
	.q(q_C_mem));
    
            
    logic [7:0]q_D;
    logic d_wren;
    d_memory
    d_memory_msg (
        .address((Mem_sel==3'b101)?shuffleB_D_Address: Check_Address),//TODO replace value
        .clock(clk),
        .data((Mem_sel==3'b101)?shuffleB_D_Data: 8'b0),//TODO replace value
        .wren((Mem_sel==3'b101)?d_wren: 1'b0), //TODO replace value
        .q(q_D)
    );

//=======================================================================================================================
//
//   Checker (task 3) 
//
//========================================================================================================================
    
    logic Checker_Finish, Decrypt_Valid;
    logic [7:0] Check_Address;
    FSM_Checker
    FSM_Checker (
    .CLOCK_50(clk),        // Clock pin
    .rst(reset_n), .Checker_Start(Decrypt_Start),
    .Finish_ack(Decrypt_done),
    .q_D(q_D),
    .Checker_Finish(Checker_Finish),
    .Address(Check_Address),
    .Decrypt_Valid(Decrypt_Valid)
);

    SevenSegmentDisplayDecoder
    decoder0 (
        .ssOut(HEX0),
        .nIn  (Secret_Key_Instance[3:0])
    );
    SevenSegmentDisplayDecoder
    decoder1 (
        .ssOut(HEX1),
        .nIn  (Secret_Key_Instance[7:4])
    );
    SevenSegmentDisplayDecoder
    decoder2 (
        .ssOut(HEX2),
        .nIn  (Secret_Key_Instance[11:8])
    );
    SevenSegmentDisplayDecoder
    decoder3 (
        .ssOut(HEX3),
        .nIn  (Secret_Key_Instance[15:12])
    );
    SevenSegmentDisplayDecoder
    decoder4 (
        .ssOut(HEX4),
        .nIn  (Secret_Key_Instance[19:16])
    );
    SevenSegmentDisplayDecoder
    decoder5 (
        .ssOut(HEX5),
        .nIn  (Secret_Key_Instance[23:20])
    );
endmodule 
`default_nettype wire